# gvmodel

`gvmodel` estimates two parameters for each person from remote associates test (RAT/CRA) responses:

- **spreading breadth** (*b*, logit scale): how far activation spreads from the cues over a word-association network,
  which determines which words come to mind, including incorrect ones;
- **verification ability** (*v*): how easily the solution is recognized once it comes to mind.

The generation–verification model predicts which word each person gives on each item, including which wrong word,
and is fitted as a hierarchical Bayesian model in Stan. The person parameters are integrated out of the likelihood
exactly, so a fit to 100 participants and 24 items takes a few minutes.

## Installation

```r
install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
cmdstanr::install_cmdstan()
remotes::install_github("gxnuyuanbo-hash/gvmodel")
```

## Usage

```r
library(gvmodel)
net  <- gv_network(edges, extra_words = cues_and_solutions)   # edges: from, to, weight (e.g., SWOW strengths)
prep <- gv_prepare(responses, items, net)                      # responses: subject, item, response ("" = no answer)
fit  <- gv_fit(prep)                                           # generation-verification model
gv_population(fit)                                             # mu, sigma, gamma, kappa, delta, tau, rho
gv_persons(fit)                                                # b and v per person, with 90% intervals
gv_screen(fit)                                                 # extreme patterns typical of careless responding
gv_compare(gv = fit, shared = gv_fit(prep, "shared"))          # PSIS-LOO comparison of model versions
```

`vignettes/tutorial.Rmd` walks through a complete analysis of the public data of Beucler and De Neys (2026).

## Networks

The package does not include a network. The SWOW norms (De Deyne et al., 2019; Li et al., 2025 for Mandarin) are
distributed under a CC BY-NC-ND license and must be downloaded from smallworldofwords.org.

## Design recommendations

Recovery of individual breadth depends on the number of items and the size of individual differences, not on sample
size. Use at least 24 items, report posterior intervals when comparing individuals with extreme breadth, and screen
out careless responders before reporting population parameters.

## Citation

[Article citation added on publication.]
