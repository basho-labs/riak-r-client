\name{riak_set_bucket_props_url}
\alias{riak_set_bucket_props_url}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_set_bucket_props_url(conn, bucket, props)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{conn}{
%%     ~~Describe \code{conn} here~~
}
  \item{bucket}{
%%     ~~Describe \code{bucket} here~~
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
function (conn, bucket, props) 
{
    if (is.null(opts)) {
        params <- ""
    }
    else {
        additional_params <- c(url_param("n_val", props$NVal), 
            url_param("allow_mult", props$AllowMult), url_param("last_write_wins", 
                props$LastWriteWins), url_param("precommit", 
                props$PreCommit), url_param("postcommit", props$PostCommit), 
            url_param("r", props$R), url_param("w", props$W), 
            url_param("dw", props$DW), url_param("rw", props$RW), 
            url_param("backend", props$Backend))
        params <- make_query_string(additional_params)
    }
    url <- paste(riak_base_url(conn), bucket, "props", sep = "/")
    paste(url, params, sep = "")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
