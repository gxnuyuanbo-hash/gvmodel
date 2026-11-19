#' Population parameters
#'
#' @param x object from [gv_fit()].
#' @param prob width of the central credible interval (default .90).
#' @return data frame with posterior mean and interval of each population parameter: mu and sigma (mean and SD of
#'   logit breadth), gamma (score weight), kappa (utility of no answer), delta and tau (mean and SD of verification
#'   ability), rho (correlation of breadth and verification ability).
gv_population <- function(x, prob = .90) {
  a <- (1 - prob) / 2
  M <- posterior::as_draws_matrix(x$fit$draws(x$params))
  data.frame(parameter = x$params, mean = unname(colMeans(M)), lower = unname(apply(M, 2, stats::quantile, a)),
             upper = unname(apply(M, 2, stats::quantile, 1 - a)))
}

#' Person parameters
#'
#' @param x object from [gv_fit()].
#' @param prob width of the central credible interval (default .90).
#' @return data frame with one row per participant: posterior mean and interval of logit breadth (`b_*`) and, for
#'   the generation-verification model, of verification ability (`v_*`), plus observed accuracy and the share of
#'   no-answer responses.
gv_persons <- function(x, prob = .90) {
  a <- (1 - prob) / 2; d <- x$data$prod
  B <- posterior::as_draws_matrix(x$fit$draws("b_draw"))
  out <- data.frame(subject = x$data$subjects, b_mean = colMeans(B), b_lower = apply(B, 2, quantile, a),
                    b_upper = apply(B, 2, quantile, 1 - a))
  if (x$model == "gv") {
    V <- posterior::as_draws_matrix(x$fit$draws("v_draw"))
    out$v_mean <- colMeans(V); out$v_lower <- apply(V, 2, quantile, a); out$v_upper <- apply(V, 2, quantile, 1 - a)
  }
  y <- d$yk; obs <- y >= 0; corr <- sweep(y, 2, d$nsol, `<=`) & y >= 1
  out$accuracy <- rowSums(corr) / rowSums(obs); out$no_answer <- rowSums(y == 0) / rowSums(obs)
  rownames(out) <- NULL; out
}

#' Screening statistics for careless responding
#'
#' Careless responders occupy extreme positions in the posterior: random responders show very high breadth and very
#' low verification ability, give-up responders very low breadth (simulation 3 of the accompanying article). This
#' function standardizes each participant's posterior means against the estimated population and ranks participants
#' by how extreme they are. It does not decide who is careless; inspect the flagged cases before excluding anyone.
#'
#' @param x object from [gv_fit()] (generation-verification model).
#' @param z threshold on the standardized posterior mean breadth used for flagging (default 2).
#' @return person table from [gv_persons()] with `b_z`, `v_z`, `pattern` ("high breadth, low verification",
#'   "low breadth", or ""), ordered from most to least extreme.
gv_screen <- function(x, z = 2) {
  stopifnot(x$model == "gv")
  p <- gv_persons(x); s <- stats::setNames(gv_population(x)$mean, gv_population(x)$parameter)
  p$b_z <- (p$b_mean - s["mu"]) / s["sigma"]; p$v_z <- (p$v_mean - s["delta"]) / s["tau"]
  p$pattern <- ifelse(p$b_z > z & p$v_z < 0, "high breadth, low verification", ifelse(p$b_z < -z, "low breadth", ""))
  p[order(-abs(p$b_z)), ]
}

#' Compare fitted models by participant-wise PSIS-LOO
#'
#' @param ... named `gv_fit` objects fitted to the same data.
#' @return the comparison table of [loo::loo_compare()] (elpd differences and standard errors).
gv_compare <- function(...) {
  fits <- list(...); if (is.null(names(fits)) || any(names(fits) == "")) names(fits) <- vapply(fits, `[[`, "", "model")
  loos <- lapply(fits, function(f) loo::loo(f$fit$draws("log_lik", format = "matrix"),
                                            r_eff = loo::relative_eff(exp(f$fit$draws("log_lik", format = "array")))))
  loo::loo_compare(loos)
}
