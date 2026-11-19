\name{gv_population}
\alias{gv_population}
\title{Population parameters}
\usage{gv_population(x, prob = .90)}
\arguments{
\item{x}{object from gv_fit().}
\item{prob}{width of the central credible interval (default .90).}
}
\description{Population parameters}
\value{data frame with posterior mean and interval of each population parameter: mu and sigma (mean and SD of logit breadth), gamma (score weight), kappa (utility of no answer), delta and tau (mean and SD of verification ability), rho (correlation of breadth and verification ability).}
