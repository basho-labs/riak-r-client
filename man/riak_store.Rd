\name{riak_store}
\alias{riak_store}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_store(conn, obj, opts = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{conn}{
%%     ~~Describe \code{conn} here~~
}
  \item{obj}{
%%     ~~Describe \code{obj} here~~
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
function (conn, obj, opts = NULL) 
{
    path <- riak_store_url(conn, obj$bucket, obj$key)
    expected_codes <- c(200, 201, 204, 300)
    if (is.null(obj$key)) {
        accept_json()
        headers <- riak_store_headers_post(obj$content_type, 
            opts, obj$vclock)
        result <- POST(path, body = obj$value, add_headers(headers))
        result
        if (opts$ReturnBody == TRUE) {
            content(riak_check_status(conn, expected_codes, result))
        }
        else {
            result
        }
    }
    else {
        accept_json()
        headers <- riak_store_headers_put(obj$content_type, opts, 
            obj$vclock)
        result <- PUT(path, body = obj$value, add_headers(headers))
        if (opts$ReturnBody == TRUE) {
            content(riak_check_status(conn, expected_codes, result))
        }
        else {
            result
        }
    }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
