#' Build a word-association network for spreading activation
#'
#' @param edges data frame with columns `from`, `to`, `weight` (e.g., SWOW cue, response, R123 strength).
#' @param extra_words words that must be nodes even if they never occur as `from` (e.g., cues and solutions).
#' @param symmetrize if TRUE (default), weights are replaced by (W + t(W)) / 2.
#' @return list with `nodes` (character), `Pt` (transpose of the row-normalized transition matrix, sparse),
#'   `pi` (stationary distribution), and `deg` (weighted degree).
#' @details Nodes are all `from` words plus `extra_words`; edges to words that are not nodes and self-loops are
#'   dropped and duplicate pairs are summed, as in the analyses of the accompanying article.
gv_network <- function(edges, extra_words = character(), symmetrize = TRUE) {
  stopifnot(all(c("from", "to", "weight") %in% names(edges)))
  from <- tolower(trimws(edges$from)); to <- tolower(trimws(edges$to)); w <- as.numeric(edges$weight)
  nodes <- sort(unique(c(from, tolower(trimws(extra_words)))), method = "radix")
  keep <- to %in% nodes & from != to & is.finite(w)
  i <- match(from[keep], nodes); j <- match(to[keep], nodes)
  W <- Matrix::sparseMatrix(i = i, j = j, x = w[keep], dims = c(length(nodes), length(nodes)))  # duplicates are summed
  if (symmetrize) W <- (W + Matrix::t(W)) / 2
  deg <- Matrix::rowSums(W)
  P <- Matrix::Diagonal(x = 1 / ifelse(deg > 0, deg, 1)) %*% W
  list(nodes = nodes, Pt = methods::as(Matrix::t(P), "CsparseMatrix"), pi = deg / sum(deg), deg = deg)
}
