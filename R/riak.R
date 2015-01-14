#' @import httr
#' @import RCurl
#' @import bitops
#' @import jsonlite

# -----------------------------------------------------------------------------
# top level functions: connect, ping, status etc
# -----------------------------------------------------------------------------

# connect to a riak cluster
#' @export
riak_http_connection <- function(host, port, https=FALSE) {
  conn <- list(riak_http_host = host, riak_http_port = port, secure=https)
  class(conn) <- "riak_connection"
  conn
}

# print the connection details
#' @export
print.riak_connection <- function(conn) {
  if(conn$secure== TRUE) {
    proto <- "https"
  } else {
    proto <- "http"
  }
  p <- paste(proto, conn$riak_http_host, conn$riak_http_port, sep=",")
  url <- paste(proto, "://", conn$riak_http_host, ":", conn$riak_http_port, sep="")
  paste("Riak http connection (", url, ")")
}

# check response code against a list of expected response codes
#' @export
riak_check_status <- function(conn, expected_codes, response) {
  status_code <- response$status_code
  if(any(expected_codes == status_code)) {
    response
  } else {
    # TODO - better error handling
    print(content(response, as="text"))
    simpleError("Error in response from Riak")
  }
}

# check if the riak cluster is running
#' @export
riak_ping <- function(conn) {
  path <- riak_ping_url(conn)
  expected_codes = c(200)
  result <- GET(path)
  res <- riak_check_status(conn, expected_codes, result)
  content(res, as="text")
}

# status query against the riak cluster
#' @export
riak_status <- function(conn, as="json") {
  path <- riak_stats_url(conn)
  expected_codes = c(200)
  
  # TODO: fix headers
  if(as == "json") {
    accept <- "application/json"
  } else {
    accept <- "text/plain"
  }
  result <- GET(path, add_headers(Accept = accept))
  res <- riak_check_status(conn, expected_codes, result)
  if (as == "json") {
    fromJSON(content(res, as="text"))
  } else {
    content(res, as="text")
  }
}


# -----------------------------------------------------------------------------
# top level functions: CRUD
# -----------------------------------------------------------------------------

# get a JSON encoded object from RIAK
#' @export
riak_fetch <- function(conn, bucket_type, bucket, key, json=TRUE, opts=NULL) {
  result <- riak_fetch_raw(conn, bucket_type, bucket, key, opts)
  expected_codes <- c(200, 202, 300, 304)
  status_code <- result$status_code
  if (any(expected_codes == status_code)) {
    if (json) {
      res.json <- content(result, as="text")
      res.obj <- fromJSON(res.json)
    } else {
      res.obj <- content(result, as="raw")
    }
    return(res.obj)
  } else if (status_code == 404) {
    return("404: Object Not Found")
  } else {
    simpleError("Error fetching value from Riak")
  }
}


# Store value in bucket as key. Defaults to formatting it as json
#' @export
riak_store <- function(conn, bucket_type, bucket, key, value, json=TRUE, opts=list("ReturnBody"=TRUE)) {
  
  stopifnot(!is.null(bucket_type))
  stopifnot(!is.null(bucket))
  stopifnot(!is.null(key))
  stopifnot(!is.null(value))
  
  path <- riak_store_url(conn, bucket_type, bucket, key)
  expected_codes <- c(200, 201, 204, 300)
  
  if (json) {
    # JSON encode object
    content_type <- "application/json"
    value <- toJSON(value, digits=16, auto_unbox=TRUE)
  } else {
    # Binary
    content_type <- "application/octet-stream"
  }
  
  # Package object
  obj <- riak_new_object(value, bucket_type, bucket, key, content_type)
    
  accept_json()
  headers <- riak_store_headers_put(obj$content_type, opts, obj$vclock)
  result <- PUT(path, body=obj$value, add_headers(headers))
  if(opts$ReturnBody == TRUE) {
    res <- riak_check_status(conn, expected_codes, result)
    content(res, as="text")
  } else {
    result
  }
}


# remove an object from the store
#' @export
riak_delete <- function(conn, bucket_type, bucket, key, opts=NULL) {
  path <- riak_delete_url(conn, bucket_type, bucket, key)
  expected_codes <- c(204, 404)
  # 404 responses are “normal” in the sense that DELETE operations are idempotent
  # and not finding the resource has the same effect as deleting it.
  result <- DELETE(path)
  result
}

# -----------------------------------------------------------------------------
#  internal helper functions
# -----------------------------------------------------------------------------
#### Code to generate URL's

url_param <- function(name, value) {
  if(is.null(value)) {
    NULL
  } else {
    if(is.logical(value)) {
      paste(name,"=",curlEscape(tolower(value)), sep="")
    } else {
      paste(name,"=",curlEscape(value), sep="")
    }
  }
}

# create a query string from a vector of params
make_query_string <- function(params) {
  params2 <- paste(params, collapse="&")
  paste("?", params2, sep="")
}

riak_base_url <- function(conn) {
  if(conn$secure == TRUE) {
    proto <- "https"
  } else {
    proto <- "http"
  }
  base_url <- paste(proto, "://", conn$riak_http_host, ":", conn$riak_http_port, sep="")
  base_url
}

riak_fetch_url <- function(conn, bucket_type, bucket, key, opts=NULL) {
  if(is.null(opts)) {
    params <- ""
  } else {
    additional_params <- c(url_param("r", opts$R),
                           url_param("pr", opts$PR),
                           url_param("basic_quorum", opts$BasicQuorum),
                           url_param("notfound_ok", opts$NotFoundOk),
                           url_param("vtag", opts$VTag))
    params <- make_query_string(additional_params)
  }
  url <- paste(riak_base_url(conn), "types", bucket_type, "buckets", bucket, "keys", key, sep="/")
  paste(url, params, sep="")
}

riak_store_url <- function(conn, bucket_type, bucket, key=NULL, opts=NULL) {
  if(is.null(opts)) {
    params <- ""
  } else {
    additional_params <- c(url_param("w", opts$W),
                           url_param("dw", opts$DW),
                           url_param("pw", opts$PW),
                           url_param("returnbody",opts$ReturnBody))
    params <- make_query_string(additional_params)
  }
  if(is.null(key)) {
    url <- paste(riak_base_url(conn), "types", bucket_type, "buckets", bucket, "keys", sep="/")
  } else {
    url <- paste(riak_base_url(conn), "types", bucket_type, "buckets", bucket, "keys", key, sep="/")
  }
  paste(url, params, sep="")
}


riak_delete_url <- function(conn, bucket_type, bucket, key, opts=NULL) {
  if(is.null(opts)) {
    params <- ""
  } else {
    additional_params <- c(url_param("rw", opts$RW),
                           url_param("r", opts$R),
                           url_param("pr", opts$PR),
                           url_param("w", opts$W),
                           url_param("dw", opts$DW),
                           url_param("pw", opts$PW))
    params <- make_query_string(additional_params)
  }
  url <- paste(riak_base_url(conn), "types", bucket_type, "buckets", bucket, "keys", key, sep="/")
  paste(url, params, sep="")  
}

riak_delete_url2 <- function(conn, bucket, key) {
  if(is.null(opts)) {
    params <- ""
  } else {
    additional_params <- c(url_param("rw", opts$RW),
                           url_param("r", opts$R),
                           url_param("pr", opts$PR),
                           url_param("w", opts$W),
                           url_param("dw", opts$DW),
                           url_param("pw", opts$PW))
    params <- make_query_string(additional_params)
  }
  url <- paste(riak_base_url(conn), "buckets", bucket, "keys", key, sep="/")
  paste(url, params, sep="")  
}


riak_ping_url <- function(conn) {
  paste(riak_base_url(conn), "/ping", sep="")
}

riak_stats_url <- function(conn) {
  paste(riak_base_url(conn), "/stats", sep="")
}


riak_new_json_object <- function(value, bucket_type, bucket, key=NULL, vclock=NULL, meta=NULL, index=NULL, link=NULL) {
  list(value=value, bucket_type=bucket_type, bucket=bucket, key=key, content_type="application/json",
       vclock=vclock, meta=meta, index=index, link=link )
}

riak_new_object <- function(value, bucket_type, bucket, key=NULL, content_type, vclock=NULL, meta=NULL, index=NULL, link=NULL) {
  list(value=value, bucket_type, bucket=bucket, key=key, content_type=content_type,
       vclock=vclock, meta=meta, index=index, link=link )
}

riak_store_headers_put <- function(content_type, opts, vclock) {
  c("Content-Type"=content_type,
    "If-None-Match"=opts$IfNoneMatch,
    "If-Match"=opts$IfMatch,
    "If-Modified-Since"=opts$IfModifiedSince,
    "If-Unmodified-Since"=opts$IfUnmodifiedSince,
    "X-Riak-Vclock"=vclock)
}

# TODO: need meta, indexes, links
riak_store_headers_post <- function(content_type, opts, vclock) {
  c("Content-Type"=content_type,
    "X-Riak-Vclock"=vclock)
}


# returns the entire HTTP response
riak_fetch_raw <- function(conn, bucket_type, bucket, key, opts=NULL) {
  path <- riak_fetch_url(conn, bucket_type, bucket, key, opts)
  GET(path, add_headers(riak_fetch_headers(opts)))
}

riak_fetch_headers <- function(opts) {
  # This will filter out NULL header options automatically
  c("If-None-Match"=opts$IfNoneMatch,
    "If-Modified-Since"=opts$IfModifiedSince)
}


