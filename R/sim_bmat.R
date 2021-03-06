#' Randomly Generate FMP Parameters
#'
#' Generate monotonic polynomial coefficients for user-specified item
#' complexities and prior distributions.
#'
#' @param n_items Number of items for which to simulate item parameters.
#' @param k Either a scalar for the item complexity of all items or a
#' vector of length n_items if different items have different item complexities.
#' @param ncat Vector of length n_item giving the number of response
#' categories for each item. If of length 1, all items will have the same
#' number of response categories.
#' @param xi_dist List of information about the distribution from which to 
#' randomly sample xi parameters. The first element should be a function that
#' generates random deviates (e.g., runif or rnorm), and further elements 
#' should be named arguments to the function.
#' @param omega_dist List of information about the distribution from which to 
#' randomly sample omega parameters. The first element should be a function that
#' generates random deviates (e.g., runif or rnorm), and further elements 
#' should be named arguments to the function.
#' @param alpha_dist List of information about the distribution from which to 
#' randomly sample alpha parameters. The first element should be a function that
#' generates random deviates (e.g., runif or rnorm), and further elements 
#' should be named arguments to the function.
#' Ignored if all k = 0.
#' @param tau_dist List of information about the distribution from which to 
#' randomly sample tau parameters. The first element should be a function that
#' generates random deviates (e.g., runif or rnorm), and further elements 
#' should be named arguments to the function.
#' Ignored if all k = 0.
#'
#' @return
#' \item{bmat}{Item parameters in the b parameterization (polynomial
#' coefficients).}
#' \item{greekmat}{Item parameters in the Greek-letter parameterization}
#'
#' @details Randomly generate FMP item parameters for a given k value.
#'
#' @examples
#' ## generate FMP item parameters for 5 dichotomous items all with k = 2
#' set.seed(2342)
#' pars <- sim_bmat(n_items = 5, k = 2)
#' pars$bmat
#'
#' ## generate FMP item parameters for 5 items with varying k values and 
#' ##  varying numbers of response categories
#' set.seed(2432)
#' pars <- sim_bmat(n_items = 5, k = c(1, 2, 0, 0, 2), ncat = c(2, 3, 4, 5, 2))
#' pars$bmat
#'
#' @importFrom stats runif
#' @export

sim_bmat <- function(n_items, k,
                     ncat = 2,
                     xi_dist = list(runif, min = -1, max = 1),
                     omega_dist = list(runif, min = -1, max = 1),
                     alpha_dist = list(runif, min = -1, max = .5),
                     tau_dist = list(runif, min = -3, max = 0)) {

  maxk <- max(k)

  maxncat <- max(ncat)

  bmat <- matrix(0, nrow = n_items, ncol = 2 * maxk + maxncat)

  if (length(k) == 1) k <- rep(k, n_items)

  if (length(k) != n_items)
    stop("k must either have 1 or n_items elements")

  if (length(ncat) == 1) ncat <- rep(ncat, n_items)

  if (length(ncat) != n_items)
    stop("ncat must either have 1 or n_items elements")

  # randomly draw xi and omega parameters
  xi <- matrix(do.call(xi_dist[[1]], 
                       c(list(n = n_items * (maxncat - 1)), xi_dist[-1])),
               ncol = maxncat - 1)
  
  omega <- do.call(omega_dist[[1]], c(list(n = n_items), omega_dist[-1]))
  
  # randomly draw alpha and tau parameters
  alpha <- matrix(0, nrow = n_items, ncol = maxk)
  tau <- matrix(-Inf, nrow = n_items, ncol = maxk)

  for (i in 1:n_items) {
    if (ncat[i] < maxncat) xi[i, ncat[i]:ncol(xi)] <- NA 
    xi[i, 1:(ncat[i] - 1)] <- sort(xi[i, 1:(ncat[i] - 1)], decreasing = TRUE)
    if (k[i] != 0) {
      alpha[i, 1:k[i]] <- do.call(alpha_dist[[1]], 
                                  c(list(n = k[i]), alpha_dist[-1]))
      tau[i, 1:k[i]] <- do.call(tau_dist[[1]],
                                c(list(n = k[i]), tau_dist[-1]))
      bmat[i, ] <- greek2b(xi = xi[i, ], omega = omega[i],
                           alpha = alpha[i, ], tau = tau[i, ])
    } else bmat[i, 1:maxncat] <- greek2b(xi = xi[i, ], omega = omega[i])
  }

  # bind together greekmat
  greekmat <- matrix(rbind(alpha, tau), nrow = n_items)
  greekmat <- cbind(xi, omega, greekmat)

  # make nice column names
  if (maxk == 0) colnames(greekmat) <- c(paste0("xi", 1:(maxncat - 1)),
                                         "omega") else
    colnames(greekmat) <- c(paste0("xi", 1:(maxncat - 1)), "omega",
                            paste0(rep(c("alpha", "tau"), maxk),
                                   rep(1:maxk, each = 2)))
  if (maxncat > 2)
    colnames(bmat) <- c(paste0("b0_", 1:(maxncat - 1)),
                        paste0("b", 1:(2 * maxk + 1))) else
      colnames(bmat) <- paste0("b", 0:(ncol(bmat) - 1))

  # output both bmat and greekmat
  list(bmat = bmat, greekmat = greekmat)
}
