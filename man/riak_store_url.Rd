\name{riak_store_url}
\alias{riak_store_url}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_store_url(conn, bucket, key = NULL, opts = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{conn}{
%%     ~~Describe \code{conn} here~~
}
  \item{bucket}{
%%     ~~Describe \code{bucket} here~~
}
  \item{key}{
%%     ~~Describe \code{key} here~~
}
  \item{opts}{
%%     ~~Describe \code{opts} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (conn, bucket, key = NULL, opts = NULL) 
{
    if (is.null(opts)) {
        params <- ""
    }
    else {
        additional_params <- c(url_param("w", opts$W), url_param("dw", 
            opts$DW), url_param("pw", opts$PW), url_param("returnbody", 
            opts$ReturnBody))
        params <- make_query_string(additional_params)
    }
    if (is.null(key)) {
        url <- paste(riak_base_url(conn), "buckets", bucket, 
            "keys", sep = "/")
    }
    else {
        url <- paste(riak_base_url(conn), "buckets", bucket, 
            "keys", key, sep = "/")
    }
    paste(url, params, sep = "")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
