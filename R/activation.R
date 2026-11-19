#' Per-cue spreading activation on a breadth grid
#'
#' Computes a_c(theta) = (1 - theta) sum_t theta^t (P^T)^t e_c for one cue, evaluated for selected words on a grid of
#' logit breadth values. For theta <= .5 the plain series is used; for theta > .5 the stationary distribution is
#' subtracted first (deflated series), which keeps the computation exact as theta approaches 1.
#'
#' @param net network from [gv_network()].
#' @param cue a single cue word.
#' @param words words whose activation is returned.
#' @param grid logit breadth values (default: 81 points from -10 to 10).
#' @param steps number of series terms (default 250; the residual is negligible on SWOW-sized networks).
#' @param all_at_half if TRUE, also return the activation of all nodes at theta = .5 (used to rank candidates).
#' @return list with `logA` (length(words) x length(grid) matrix of log activation) and optionally `half`.
gv_activation <- function(net, cue, words, grid = seq(-10, 10, length.out = 81), steps = 250, all_at_half = FALSE) {
  n <- length(net$nodes); ci <- match(tolower(cue), net$nodes); wi <- match(tolower(words), net$nodes)
  if (is.na(ci)) stop("cue not in network: ", cue)
  if (anyNA(wi)) stop("words not in network: ", paste(words[is.na(wi)], collapse = ", "))
  th <- 1 / (1 + exp(-grid)); lo <- th <= .5
  a0 <- numeric(n); a0[ci] <- 1
  V <- cbind(a0, a0 - net$pi)                       # plain and deflated series
  acc_lo <- matrix(0, length(wi), sum(lo)); acc_hi <- matrix(0, length(wi), sum(!lo)); half <- numeric(n)
  pl <- rep(1, sum(lo)); ph <- rep(1, sum(!lo)); p5 <- 1
  for (t in seq_len(steps)) {
    acc_lo <- acc_lo + outer(V[wi, 1], pl); acc_hi <- acc_hi + outer(V[wi, 2], ph)
    if (all_at_half) half <- half + V[, 1] * p5
    V <- as.matrix(net$Pt %*% V); pl <- pl * th[lo]; ph <- ph * th[!lo]; p5 <- p5 * .5
  }
  A <- matrix(0, length(wi), length(grid))
  A[, lo] <- sweep(acc_lo, 2, 1 - th[lo], `*`)
  A[, !lo] <- net$pi[wi] + sweep(acc_hi, 2, 1 - th[!lo], `*`)
  out <- list(logA = log(pmax(A, 1e-300)))
  if (all_at_half) out$half <- half * .5
  out
}
