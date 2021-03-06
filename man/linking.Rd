% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/linking.R
\name{linking}
\alias{linking}
\alias{sl_link}
\alias{hb_link}
\title{Linear and Nonlinear Item Parameter Linking}
\usage{
sl_link(
  bmat1,
  bmat2,
  maxncat = 2,
  cvec1 = NULL,
  cvec2 = NULL,
  dvec1 = NULL,
  dvec2 = NULL,
  k_theta,
  int = int_mat(),
  ...
)

hb_link(
  bmat1,
  bmat2,
  maxncat = 2,
  cvec1 = NULL,
  cvec2 = NULL,
  dvec1 = NULL,
  dvec2 = NULL,
  k_theta,
  int = int_mat(),
  ...
)
}
\arguments{
\item{bmat1}{FMP item parameters on an anchor test.}

\item{bmat2}{FMP item parameters to be rescaled.}

\item{maxncat}{Maximum number of response categories (the first maxncat - 1
columns of bmat1 and bmat2 are intercepts)}

\item{cvec1}{Vector of lower asymptote parameters for the anchor test.}

\item{cvec2}{Vector of lower asymptote parameters corresponding to the
rescaled item parameters.}

\item{dvec1}{Vector of upper asymptote parameters for the anchor test.}

\item{dvec2}{Vector of upper asymptote parameters corresponding to the
rescaled item parameters.}

\item{k_theta}{Complexity of the latent trait transformation (k_theta = 0 is
linear, k_theta > 0 is nonlinear).}

\item{int}{Matrix with two columns, used for numerical integration. Column 1
is a grid of theta values, column 2 are normalized densities associated with
the column 1 values.}

\item{\dots}{Additional arguments passed to optim.}
}
\value{
\item{par}{(Greek-letter) parameters estimated by optim.}
\item{value}{Value of the minimized criterion function.}
\item{counts}{Number of function counts in optim.}
\item{convergence}{Convergence criterion given by optim.}
\item{message}{Message given by optim.}
\item{tvec}{Vector of theta transformation coefficients
\eqn{(t = t0,....,t(2k_\theta+1))}}
\item{bmat}{Transformed bmat2 item parameters.}
}
\description{
Link two sets of FMP item parameters using linear or nonlinear
transformations of the latent trait.
}
\details{
The goal of item parameter linking is to find a metric
transformation such that the fitted parameters for one test can be
transformed to the same metric as those for the other test. In the Haebara
approach, the overall sum of squared differences between the original and
transformed individual item response functions is minimized. In the
Stocking-Lord approach, the sum of squared differences between the original
and transformed test response functions is minimized. See
Feuerstahler (2016, 2019) for details on linking with the FMP model.
}
\examples{

set.seed(2342)
bmat <- sim_bmat(n_items = 10, k = 2)$bmat

theta1 <- rnorm(100)
theta2 <- rnorm(100, mean = -1)

dat1 <- sim_data(bmat = bmat, theta = theta1)
dat2 <- sim_data(bmat = bmat, theta = theta2)

# estimate each model with fixed-effects and k = 0
fmp0_1 <- fmp(dat = dat1, k = 0, em = FALSE)
fmp0_2 <- fmp(dat = dat2, k = 0, em = FALSE)

# Stocking-Lord linking

\donttest{
sl_res <- sl_link(bmat1 = fmp0_1$bmat[1:5, ],
                  bmat2 = fmp0_2$bmat[1:5, ],
                  k_theta = 0)


hb_res <- hb_link(bmat1 = fmp0_1$bmat[1:5, ],
                  bmat2 = fmp0_2$bmat[1:5, ],
                  k_theta = 0)
}



}
\references{
Feuerstahler, L. M. (2016). \emph{Exploring alternate latent trait metrics
with the filtered monotonic polynomial IRT model} (Unpublished dissertation).
University of Minnesota, Minneapolis, MN.
\url{http://hdl.handle.net/11299/182267}

Feuerstahler, L. M. (2019). Metric Transformations and the Filtered
Monotonic Polynomial Item Response Model. \emph{Psychometrika}, \emph{84},
105--123. \doi{10.1007/s11336-018-9642-9}

Haebara, T. (1980). Equating logistic ability scales by a weighted least
squares method. \emph{Japanese Psychological Research}, \emph{22}, 144--149.
\doi{10.4992/psycholres1954.22.144}

Stocking, M. L., & Lord, F. M. (1983). Developing a common metric in item
response theory. \emph{Applied Psychological Measurement}, \emph{7},
201--210. \doi{10.1002/j.2333-8504.1982.tb01311.x}
}
