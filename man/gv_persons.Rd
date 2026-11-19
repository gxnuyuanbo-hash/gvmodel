\name{gv_persons}
\alias{gv_persons}
\title{Person parameters}
\usage{gv_persons(x, prob = .90)}
\arguments{
\item{x}{object from gv_fit().}
\item{prob}{width of the central credible interval (default .90).}
}
\description{Person parameters}
\value{data frame with one row per participant: posterior mean and interval of logit breadth (`b_*`) and, for the generation-verification model, of verification ability (`v_*`), plus observed accuracy and the share of no-answer responses.}
