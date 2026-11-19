#' Prepare remote associates responses for the generation-verification model
#'
#' @param responses data frame with columns `subject`, `item`, `response`. A missing or empty `response` codes
#'   "no answer". Responses are lower-cased and trimmed.
#' @param items data frame with columns `item`, `cues` (three cues separated by "/") and `solution` (one or more
#'   accepted solutions separated by "/").
#' @param net network from [gv_network()]. All cues and solutions must be nodes.
#' @param top number of extra candidates per item: the most activated words at theta = .5 (joint activation of the
#'   three cues) that are neither solutions nor observed responses; cue words are never candidates (default 20).
#' @param candidate_responses responses used to build candidate sets (default: `responses`). Pass the pooled
#'   responses of several samples to score them on identical candidate sets.
#' @param grid logit breadth grid (default 81 points on [-10, 10]).
#' @param n_terms candidate numbers of Chebyshev terms; the smallest with maximum absolute error below `tol` is used.
#' @param tol tolerance of the Chebyshev approximation of scores.
#' @return an object of class `gv_data`: Stan data for the multiplicative (`prod`) and additive (`sum`) scores,
#'   the candidate sets, subject and item identifiers, and a report of responses outside the candidate sets.
gv_prepare <- function(responses, items, net, top = 20, candidate_responses = responses,
                       grid = seq(-10, 10, length.out = 81), n_terms = c(12, 16, 20, 24, 28), tol = .01) {
  norm <- function(x) { x <- tolower(trimws(as.character(x))); x[is.na(x)] <- ""; x }
  responses$response <- norm(responses$response); candidate_responses$response <- norm(candidate_responses$response)
  items$item <- as.character(items$item); responses$item <- as.character(responses$item)
  candidate_responses$item <- as.character(candidate_responses$item)
  J <- nrow(items); cands <- vector("list", J); per <- vector("list", J)
  for (j in seq_len(J)) {
    cues <- strsplit(tolower(items$cues[j]), "/", fixed = TRUE)[[1]]; sols <- strsplit(tolower(items$solution[j]), "/", fixed = TRUE)[[1]]
    if (length(cues) != 3) stop("item ", items$item[j], ": three cues expected")
    if (!all(c(cues, sols) %in% net$nodes)) stop("item ", items$item[j], ": cue or solution not in network")
    obs <- candidate_responses$response[candidate_responses$item == items$item[j] & candidate_responses$response != ""]
    cand <- unique(c(sols, obs[obs %in% net$nodes & !obs %in% sols]))
    acts <- lapply(cues, function(cu) gv_activation(net, cu, sols[1], grid = 0, all_at_half = TRUE)$half)
    joint <- Reduce(`+`, acts) / 3
    extra <- 0; for (k in order(-joint)) {
      if (extra >= top) break
      w <- net$nodes[k]
      if (!w %in% cand && !w %in% cues) { cand <- c(cand, w); if (!w %in% obs) extra <- extra + 1 }
    }
    cands[[j]] <- cand
    per[[j]] <- vapply(cues, function(cu) gv_activation(net, cu, cand, grid = grid)$logA, matrix(0, length(cand), length(grid)))
    message("item ", j, "/", J, ": ", length(cand), " candidates")
  }
  K <- max(lengths(cands)); x <- (2 * grid - min(grid) - max(grid)) / (max(grid) - min(grid))
  score <- function(kind, j) { L <- per[[j]]                         # candidates x grid x 3 cues
    if (kind == "prod") apply(L, c(1, 2), sum) else apply(L, c(1, 2), function(v) max(v) + log(sum(exp(v - max(v)))) - log(3)) }
  cheb <- function(nc) { B <- matrix(1, length(x), nc); B[, 2] <- x; for (m in 3:nc) B[, m] <- 2 * x * B[, m - 1] - B[, m - 2]; B }
  fitC <- function(kind) {
    for (nc in n_terms) { B <- cheb(nc); err <- 0; co <- vector("list", J)
      for (j in seq_len(J)) { S <- score(kind, j); cf <- t(qr.solve(B, t(S))); co[[j]] <- cf; err <- max(err, abs(cf %*% t(B) - S)) }
      if (err < tol) break }
    C <- matrix(0, J * K, nc); pad <- rep(-1e4, J * K)
    for (j in seq_len(J)) { r <- (j - 1) * K + seq_along(cands[[j]]); C[r, ] <- co[[j]]; pad[r] <- 0 }
    list(C = C, pad = pad, D = nc, maxerr = err) }
  subs <- unique(as.character(responses$subject)); N <- length(subs)
  yk <- matrix(-1L, N, J); outside <- 0L
  for (r in seq_len(nrow(responses))) {
    i <- match(as.character(responses$subject[r]), subs); j <- match(responses$item[r], items$item)
    if (is.na(j)) next
    resp <- responses$response[r]
    if (resp == "") yk[i, j] <- 0L else { k <- match(resp, cands[[j]]); if (is.na(k)) outside <- outside + 1L else yk[i, j] <- k }
  }
  keep <- rowSums(yk >= 0) > 0
  nsol <- vapply(strsplit(tolower(items$solution), "/", fixed = TRUE), length, 1L)
  base <- list(N = sum(keep), J = J, K = K, lo = min(grid), hi = max(grid), nsol = as.array(nsol), yk = yk[keep, , drop = FALSE])
  structure(list(prod = c(base, fitC("prod")), sum = c(base, fitC("sum")), candidates = cands, subjects = subs[keep],
                 excluded = subs[!keep], items = items$item, outside = outside, grid = grid),
            class = "gv_data")
}

#' @export
print.gv_data <- function(x, ...) {
  cat("gv_data:", x$prod$N, "participants,", x$prod$J, "items, candidates per item", min(lengths(x$candidates)), "to",
      max(lengths(x$candidates)), "\n  responses outside the candidate sets (treated as missing):", x$outside,
      "\n  participants without any usable response (excluded):", length(x$excluded),
      "\n  Chebyshev terms:", x$prod$D, "(max error", signif(x$prod$maxerr, 2), ")\n")
  invisible(x)
}
