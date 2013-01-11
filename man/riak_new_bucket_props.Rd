\name{riak_new_bucket_props}
\alias{riak_new_bucket_props}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
riak_new_bucket_props(NVal = NULL, AllowMult = NULL, LastWriteWins = NULL, PreCommit = NULL, PostCommit = NULL, R = NULL, W = NULL, DW = NULL, RW = NULL, Backend = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{NVal}{
%%     ~~Describe \code{NVal} here~~
}
  \item{AllowMult}{
%%     ~~Describe \code{AllowMult} here~~
}
  \item{LastWriteWins}{
%%     ~~Describe \code{LastWriteWins} here~~
}
  \item{PreCommit}{
%%     ~~Describe \code{PreCommit} here~~
}
  \item{PostCommit}{
%%     ~~Describe \code{PostCommit} here~~
}
  \item{R}{
%%     ~~Describe \code{R} here~~
}
  \item{W}{
%%     ~~Describe \code{W} here~~
}
  \item{DW}{
%%     ~~Describe \code{DW} here~~
}
  \item{RW}{
%%     ~~Describe \code{RW} here~~
}
  \item{Backend}{
%%     ~~Describe \code{Backend} here~~
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
function (NVal = NULL, AllowMult = NULL, LastWriteWins = NULL, 
    PreCommit = NULL, PostCommit = NULL, R = NULL, W = NULL, 
    DW = NULL, RW = NULL, Backend = NULL) 
{
    list(NVal = NVal, AllowMult = AllowMult, LastWriteWins = LastWriteWins, 
        PreCommit = PreCommit, PostCommit = PostCommit, R = R, 
        W = W, DW = DW, RW = RW, Backend = Backend)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
