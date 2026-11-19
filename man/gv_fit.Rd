\name{gv_fit}
\alias{gv_fit}
\title{Fit the generation-verification model or one of its reduced versions}
\usage{gv_fit(data, model = c("gv", "shared", "multiplicative", "additive"), chains = 4, iter = 750, seed = 1, nodes = c(16, 8), ...)}
\arguments{
\item{data}{object from gv_prepare().}
\item{model}{one of "gv" (generation-verification, default), "shared" (shared verification), "multiplicative", "additive".}
\item{chains, iter}{number of chains and of warm-up (= sampling) iterations per chain.}
\item{seed}{random seed.}
\item{nodes}{Gauss-Hermite nodes for breadth and verification (default 16 x 8).}
\item{...}{further arguments passed to `$sample()` of cmdstanr.}
}
\description{Fit the generation-verification model or one of its reduced versions}
\value{a `gv_fit` object: the CmdStanMCMC fit, the model name, the data, and a convergence summary (R-hat <= 1.01, bulk and tail ESS >= 400, no divergent transitions).}
