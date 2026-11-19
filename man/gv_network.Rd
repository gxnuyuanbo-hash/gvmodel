\name{gv_network}
\alias{gv_network}
\title{Build a word-association network for spreading activation}
\usage{gv_network(edges, extra_words = character(), symmetrize = TRUE)}
\arguments{
\item{edges}{data frame with columns `from`, `to`, `weight` (e.g., SWOW cue, response, R123 strength).}
\item{extra_words}{words that must be nodes even if they never occur as `from` (e.g., cues and solutions).}
\item{symmetrize}{if TRUE (default), weights are replaced by (W + t(W)) / 2.}
}
\description{Build a word-association network for spreading activation}
\value{list with `nodes` (character), `Pt` (transpose of the row-normalized transition matrix, sparse), `pi` (stationary distribution), and `deg` (weighted degree).}
\details{Nodes are all `from` words plus `extra_words`; edges to words that are not nodes and self-loops are dropped and duplicate pairs are summed, as in the analyses of the accompanying article.}
