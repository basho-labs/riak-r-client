\name{riak_list_keys}
\alias{riak_list_keys}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_list_keys(conn, bucket, stream = TRUE, props = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{conn}{
%%     ~~Describe \code{conn} here~~
}
  \item{bucket}{
%%     ~~Describe \code{bucket} here~~
}
  \item{stream}{
%%     ~~Describe \code{stream} here~~
}
  \item{props}{
%%     ~~Describe \code{props} here~~
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
function (conn, bucket, stream = TRUE, props = TRUE) 
{
    path <- riak_list_keys_url(conn, bucket, stream)
    expected_codes <- c(200)
    content_type <- "application/json"
    if (stream) {
        result <- GET(path, add_headers(`Content-Type` = content_type, 
            `Transfer-Encoding` = "chunked"))
    }
    else {
        result <- GET(path, add_headers(`Content-Type` = content_type))
    }
    content(riak_check_status(conn, expected_codes, result))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
