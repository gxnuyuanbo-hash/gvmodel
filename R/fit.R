gh_nodes <- function(n) {
  if (n == 1) return(list(x = 0, w = 1))
  b <- sqrt(seq_len(n - 1) / 2); Jm <- matrix(0, n, n); Jm[cbind(1:(n - 1), 2:n)] <- b; Jm[cbind(2:n, 1:(n - 1))] <- b
  e <- eigen(Jm, symmetric = TRUE); list(x = e$values * sqrt(2), w = e$vectors[1, ]^2)
}

#' Fit the generation-verification model or one of its reduced versions
#'
#' @param data object from [gv_prepare()].
#' @param model one of "gv" (generation-verification, default), "shared" (shared verification), "multiplicative",
#'   "additive".
#' @param chains,iter number of chains and of warm-up (= sampling) iterations per chain.
#' @param seed random seed.
#' @param nodes Gauss-Hermite nodes for breadth and verification (default 16 x 8).
#' @param ... further arguments passed to `$sample()` of cmdstanr.
#' @return a `gv_fit` object: the CmdStanMCMC fit, the model name, the data, and a convergence summary
#'   (R-hat <= 1.01, bulk and tail ESS >= 400, no divergent transitions).
gv_fit <- function(data, model = c("gv", "shared", "multiplicative", "additive"), chains = 4, iter = 750, seed = 1,
                   nodes = c(16, 8), ...) {
  model <- match.arg(model); stopifnot(inherits(data, "gv_data"))
  d <- if (model == "additive") data$sum else data$prod
  use_delta <- as.integer(model %in% c("gv", "shared")); use_tau <- as.integer(model == "gv")
  Q1 <- nodes[1]; Q2 <- if (use_tau) nodes[2] else 1; g1 <- gh_nodes(Q1); g2 <- gh_nodes(Q2)
  sd <- list(N = d$N, J = d$J, K = d$K, D = d$D, lo = d$lo, hi = d$hi, C = d$C, pad = d$pad, nsol = d$nsol, yk = d$yk,
             Q1 = Q1, x1 = g1$x, lw1 = log(g1$w), Q2 = Q2, x2 = as.array(g2$x), lw2 = as.array(log(g2$w)),
             use_delta = use_delta, use_tau = use_tau, do_gq = 1L, G1 = 61L, G2 = if (use_tau) 21L else 1L)
  m <- cmdstanr::cmdstan_model(system.file("stan", "gv_model.stan", package = "gvmodel"), quiet = TRUE)
  fit <- m$sample(data = sd, chains = chains, parallel_chains = chains, iter_warmup = iter, iter_sampling = iter,
                  seed = seed, refresh = 0, show_messages = FALSE, ...)
  pv <- c("mu", "sigma", "gamma", "kappa", if (use_delta) "delta", if (use_tau) c("tau", "rho"))
  s <- fit$summary(pv); dg <- fit$diagnostic_summary(quiet = TRUE)
  conv <- list(max_rhat = max(s$rhat), min_ess = min(s$ess_bulk, s$ess_tail), divergent = sum(dg$num_divergent))
  conv$ok <- conv$max_rhat <= 1.01 && conv$min_ess >= 400 && conv$divergent == 0
  if (!conv$ok) warning("convergence criteria not met; consider refitting with more iterations (e.g., iter = 1500)")
  structure(list(fit = fit, model = model, data = data, params = pv, convergence = conv), class = "gv_fit")
}

#' @export
print.gv_fit <- function(x, ...) {
  cat("gv_fit:", x$model, "model,", x$data$prod$N, "participants;",
      if (x$convergence$ok) "converged" else "NOT converged", sprintf("(max R-hat %.3f, min ESS %d, divergent %d)\n",
      x$convergence$max_rhat, round(x$convergence$min_ess), x$convergence$divergent))
  print(gv_population(x), digits = 3); invisible(x)
}
