% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ARp.R
\name{ARp}
\alias{ARp}
\title{Autoregressive model of order \emph{p}}
\usage{
ARp(margdist, margarg, acsvalue, actfpara, n, p = NULL, p0 = 0)
}
\arguments{
\item{margdist}{target marginal distribution}

\item{margarg}{list of marginal distribution arguments}

\item{acsvalue}{target auto-correlation structure (from lag 0)}

\item{actfpara}{auto-correlation structure transformation parameters}

\item{n}{number of values}

\item{p}{integer - model order (if NULL - limits maximum model order according to auto-correlation structure values)}

\item{p0}{probability zero}
}
\description{
Generates time series from an Autoregressive model of order \emph{p}
}
\examples{

library(CoSMoS); library(ggplot2)

## choose the marginal distribution as Pareto type II with corresponding parameters
dist <- 'paretoII'
distarg <- list(scale = 1, shape = .3)
p0 <- .5

## estimate rho 'x' and 'z' points using ACTI
pnts <- actpnts(margdist = dist, margarg = distarg, p0 = p0)

## fit ACTF
fit <- fitactf(pnts)

## define target auto-correlation structure and model order
order <- 1000
acsvalue <- acs(id = 'weibull', t = 0:order, scale = 10, shape = .75)

## limit ACS lag (recomended)
system.time(val <- ARp(margdist = dist,
                       margarg = distarg,
                       acsvalue = acsvalue,
                       actfpara = fit,
                       n = 5000,
                       p0 = p0))
\donttest{
## order w/o limit
system.time(val <- ARp(margdist = dist,
                       margarg = distarg,
                       acsvalue = acsvalue,
                       actfpara = fit,
                       n = 5000,
                       p = order,
                       p0 = p0))
}

## see the result
ggplot() +
  geom_col(aes(x = seq_along(val),
               y = val)) +
  labs(x = '',
       y = 'value') +
  theme_classic()

}
\keyword{internal}
