\name{gv_activation}
\alias{gv_activation}
\title{Per-cue spreading activation on a breadth grid}
\usage{gv_activation(net, cue, words, grid = seq(-10, 10, length.out = 81), steps = 250, all_at_half = FALSE)}
\arguments{
\item{net}{network from gv_network().}
\item{cue}{a single cue word.}
\item{words}{words whose activation is returned.}
\item{grid}{logit breadth values (default: 81 points from -10 to 10).}
\item{steps}{number of series terms (default 250; the residual is negligible on SWOW-sized networks).}
\item{all_at_half}{if TRUE, also return the activation of all nodes at theta = .5 (used to rank candidates).}
}
\description{Computes a_c(theta) = (1 - theta) sum_t theta^t (P^T)^t e_c for one cue, evaluated for selected words on a grid of logit breadth values. For theta <= .5 the plain series is used; for theta > .5 the stationary distribution is subtracted first (deflated series), which keeps the computation exact as theta approaches 1.}
\value{list with `logA` (length(words) x length(grid) matrix of log activation) and optionally `half`.}
