\name{gv_prepare}
\alias{gv_prepare}
\title{Prepare remote associates responses for the generation-verification model}
\usage{gv_prepare(responses, items, net, top = 20, candidate_responses = responses, grid = seq(-10, 10, length.out = 81), n_terms = c(12, 16, 20, 24, 28), tol = .01)}
\arguments{
\item{responses}{data frame with columns `subject`, `item`, `response`. A missing or empty `response` codes "no answer". Responses are lower-cased and trimmed.}
\item{items}{data frame with columns `item`, `cues` (three cues separated by "/") and `solution` (one or more accepted solutions separated by "/").}
\item{net}{network from gv_network(). All cues and solutions must be nodes.}
\item{top}{number of extra candidates per item: the most activated words at theta = .5 (joint activation of the three cues) that are neither solutions nor observed responses; cue words are never candidates (default 20).}
\item{candidate_responses}{responses used to build candidate sets (default: `responses`). Pass the pooled responses of several samples to score them on identical candidate sets.}
\item{grid}{logit breadth grid (default 81 points on -10, 10).}
\item{n_terms}{candidate numbers of Chebyshev terms; the smallest with maximum absolute error below `tol` is used.}
\item{tol}{tolerance of the Chebyshev approximation of scores.}
}
\description{Prepare remote associates responses for the generation-verification model}
\value{an object of class `gv_data`: Stan data for the multiplicative (`prod`) and additive (`sum`) scores, the candidate sets, subject and item identifiers, and a report of responses outside the candidate sets.}
