\name{gv_compare}
\alias{gv_compare}
\title{Compare fitted models by participant-wise PSIS-LOO}
\usage{gv_compare(...)}
\arguments{
\item{...}{named `gv_fit` objects fitted to the same data.}
}
\description{Compare fitted models by participant-wise PSIS-LOO}
\value{the comparison table of loo::loo_compare() (elpd differences and standard errors).}
