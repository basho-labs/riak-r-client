# -------------------------------------------------------------------
# 
# riak.ml: Riak R Client
#
# Copyright (c) 2013 Dave Parfitt and Basho Technologies
# All Rights Reserved.
#
# This file is provided to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain
# a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Licese is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#-------------------------------------------------------------------

library(bitops)
library(RCurl)
library(httr)
library(rjson)

#### Code to generate URL's
# use the connection to determine if the URL's are using the
# new style or old style

riak_base_url <- function(conn) {
   if(conn$secure == TRUE) {
      proto <- "https"
    } else {
      proto <- "http"
    }
    base_url <- paste(proto, "://", conn$riak_http_host, ":", conn$riak_http_port, sep="")
    base_url
}

riak_fetch_url <- function(conn, bucket, key) {
    paste(riak_base_url(conn), "buckets", bucket, "keys", key, sep="/")
}

riak_store_url <- function(conn, bucket, key=NULL) {
    if(is.null(key)) {
        paste(riak_base_url(conn), "buckets", bucket, "keys", sep="/")
    } else {
        paste(riak_base_url(conn), "buckets", bucket, "keys", key, sep="/")
    }
}

riak_ping_url <- function(conn) {
    paste(riak_base_url(conn), "/ping", sep="")
}

riak_stats_url <- function(conn) {
    paste(riak_base_url(conn), "/stats", sep="")
}

riak_mapred_url <- function(conn) {
    paste(riak_base_url(conn), "/mapred", sep="")
}

riak_2i_exact_url <- function(conn, bucket, index, value) {
    chunks <- paste("buckets", bucket, "index", index, value, sep="/")
    paste(riak_base_url(conn), chunks, sep="/")
}

riak_2i_range_url <- function(conn, bucket, index, minvalue, maxvalue) {
    chunks <- paste("buckets", bucket, "index", index, minvalue, maxvalue, sep="/")
    paste(riak_base_url(conn), chunks, sep="/")
}

riak_list_keys_url <- function(conn, bucket, stream=TRUE) {
    if(stream) {
        chunks <- paste("buckets", bucket, "keys?keys=stream", sep="/")
        paste(riak_base_url(conn), chunks, sep="/")
    } else {
        chunks <- paste("buckets", bucket, "keys?keys=true", sep="/")
        paste(riak_base_url(conn), chunks, sep="/")
    }
}


### Riak operations

riak_http_connection <- function(host, port, https=FALSE) {
    conn <- list(riak_http_host = host, riak_http_port = port, secure=https)
    class(conn) <- "riak_connection"
    conn
}

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
riak_check_status <- function(conn, expected_codes, response) {
     status_code <- response$status_code
    if(any(expected_codes == status_code)) {
        response
    } else {
        # TODO - better error handling
        simpleError("Error in response from Riak")
    }
}

riak_ping <- function(conn) {
    path <- riak_ping_url(conn)
    expected_codes = c(200)
    result <- GET(path)
    riak_check_status(conn, expected_codes, result)
}

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
    content(riak_check_status(conn, expected_codes, result))
}

# riak_fetch_raw returns the entire HTTP response
# you'll need to decode the response using content()
riak_fetch_raw <- function(conn, bucket, key) {
    path <- riak_fetch_url(conn, bucket, key)
    expected_codes <- c(200, 300, 304)
    result <- GET(path)
    status_code <- result$status_code
    if(any(expected_codes == status_code)) {
        result
    } else {
        # TODO
        simpleError("Error fetching value from Riak")
    }
}

riak_fetch <- function(conn, bucket, key) {
    result <- riak_fetch_raw(conn, bucket, key)
    content(result, as="parsed")
}

riak_new_json_object <- function(value, bucket, key=NULL, vclock=NULL, meta=NULL, index=NULL, link=NULL) {
    list(value=value, bucket=bucket, key=key, content_type="application/json",
         vclock=vclock, meta=meta, index=index, link=link )
}

riak_new_object <- function(value, bucket, key=NULL, content_type, vclock=NULL, meta=NULL, index=NULL, link=NULL) {
    list(value=value, bucket=bucket, key=key, content_type=content_type,
         vclock=vclock, meta=meta, index=index, link=link )
}

# TODO: make case in options consistent
riak_new_store_options <- function(W=NULL, DW=NULL, PW=NULL, ReturnBody=FALSE, IfNoneMatch=NULL,
                                   IfMatch=NULL, IfModifiedSince=NULL, IfUnmodifiedSince=NULL,
                                   ETag=NULL, LastModified=NULL) {
  list(W=W, DW=DW, PW=PW, ReturnBody=ReturnBody, IfNoneMatch=IfNoneMatch,
       IfMatch=IfMatch, IfModifiedSince=IfModifiedSince,
       IfUnmodifiedSince=IfUnmodifiedSince, IfNoneMatch=IfNoneMatch)
}

# TODO: make case in options consistent
riak_new_fetch_options <- function(R=NULL, PR=NULL, BasicQuorum=NULL,
                                   NotFoundOk=NULL, VTag=NULL, IfNoneMatch=NULL,
                                   IfModifiedSince=NULL) {
  list(R=R, PR=PR, BasicQuorum=BasicQuorum, NotFoundOk=NotFoundOk,
       VTag=VTag, IfNoneMatch=IfNoneMatch, IfModifiedSince=IfModifiedSince)
}


#TODO: check for location, PUT vs POST options
riak_store <- function(conn, obj, options=NULL) {
    if(is.null(options)) {
        options = riak_new_store_options()
    }
    path <- riak_store_url(conn, obj$bucket, obj$key)
    expected_codes <- c(200, 201, 204, 300)

    if(is.null(obj$key)) {
        accept_json()
        result <- POST(path, body=obj$value,
                       add_headers("Content-Type" = obj$content_type))
        result
        if(options$ReturnBody == TRUE) {
          content(riak_check_status(conn, expected_codes, result))
        } else {
          result
        }
    } else {
        accept_json()
        result <- PUT(path, body=obj$value,
                      add_headers("Content-Type" = obj$content_type))
        if(options$ReturnBody == TRUE) {
          content(riak_check_status(conn, expected_codes, result))
        } else {
          result
        }
    }
}

riak_2i_exact <- function(conn, bucket, index, value) {
    path <- riak_2i_exact_url(conn, bucket, index, value)
    expected_codes <- c(200)
    result <- GET(path)
    content(riak_check_status(conn, expected_codes, result))
}

riak_2i_range <- function(conn, bucket, index, minvalue, maxvalue) {
    path <- riak_2i_range_url(conn, bucket, index, minvalue, maxvalue)
    expected_codes <- c(200)
    result <- GET(path)
    content(riak_check_status(conn, expected_codes, result))
}

## TODO: cleanup, make a riak_new_mr object w/ all M/R params
riak_mapreduce <- function(conn, query) {
    # TODO: chunked option
    path <- riak_mapred_url(conn)
    expected_codes <- c(200)
    add_headers("ContentType: application/json")
    result <- POST(path)
    content(riak_check_status(conn, expected_codes, result))
}

# TODO: use props
riak_list_keys <- function(conn, bucket, stream=TRUE, props=TRUE) {
    path <- riak_list_keys_url(conn, bucket, stream)
    expected_codes <- c(200)
    content_type <- "application/json"
    if(stream) {
        result <- GET(path, add_headers("Content-Type" = content_type,
                                        "Transfer-Encoding" = "chunked"))
    } else {
        result <- GET(path,
            add_headers("Content-Type" = content_type))
    }
    content(riak_check_status(conn, expected_codes, result))
}
