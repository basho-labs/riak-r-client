\name{riak_new_json_object}
\alias{riak_new_json_object}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_new_json_object(value, bucket, key = NULL, vclock = NULL, meta = NULL, index = NULL, link = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{value}{
%%     ~~Describe \code{value} here~~
}
  \item{bucket}{
%%     ~~Describe \code{bucket} here~~
}
  \item{key}{
%%     ~~Describe \code{key} here~~
}
  \item{vclock}{
%%     ~~Describe \code{vclock} here~~
}
  \item{meta}{
%%     ~~Describe \code{meta} here~~
}
  \item{index}{
%%     ~~Describe \code{index} here~~
}
  \item{link}{
%%     ~~Describe \code{link} here~~
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
function (value, bucket, key = NULL, vclock = NULL, meta = NULL, 
    index = NULL, link = NULL) 
{
    list(value = value, bucket = bucket, key = key, content_type = "application/json", 
        vclock = vclock, meta = meta, index = index, link = link)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
