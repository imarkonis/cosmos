#' Seasonal AR model
#'
#' @param x vector of dates for gaussian process generation
#' @param ACS list of ACS for each season
#' @param season season name
#'
#' @keywords internal
#' @import data.table
#' @export
#'
#' @examples
#'
#' x <- data.frame(date = seq(Sys.Date(), by = 'day', length.out = 1000),
#'                 value = rnorm(1000))
#'
#' sacf <- seasonalACF(x, 'month')
#'
#' y <- suppressWarnings((seasonalAR(x$date, sacf)))
#'
seasonalAR <- function(x, ACS, season = 'month') {

  time <- data.table(time = x)

  y <- s <- n <- . <- id <- value <- NULL ## global variable check

  time[, y := year(time)]
  time[, s := do.call(season, .(time))]
  time[, n := .N, by = .(y, s)]

  d <- as.data.frame(unique(time[, -1])) ## main dataframe of seasons and number of values to be generated per season

  alpha <- lapply(ACS, YW) ## pars for the seasonal models

  out <- data.table(value = AR1(max(sapply(alpha, length)), alpha[[d[1, 's']]][1])) ## overal init values
  out[, id := 0]

  # out <- c(AR1(max(sapply(alpha, length)), alpha[[d[1, 's']]][1])) ## overal init values

  esd <- c()

  for (i in seq_along(alpha)) { ## sd for gaussian noise

    esd[i] <- sqrt(1 - sum(ACS[[i]][2:length(ACS[[i]])]*alpha[[i]]))
  }


  for (j in 1:dim(d)[1]) {

    s <- d[j, 's'] ## season selection

    p <- length(alpha[[s]]) ## model order

    # val <- c(out[(length(out) + 1 - p):length(out)]) ## initial value
    val <- out[(dim(out)[1] + 1 - p):dim(out)[1], value] ## initial value

    aux <- length(val)

    n <- unlist(d[j, 'n']) ## number od values to gen in a seasonal run

    gn <- rnorm(n + p, ## gaussian noise
                mean = 0,
                sd = esd[s])

    a.rev <- rev(alpha[[s]]) ## alpha in the correct order

    for (i in (p + 1):(n + p)) { ## AR
      val[i] <- sum(val[(i - p):(i - 1)]*a.rev) + gn[i]
    }

    # val <- val[-((length(val) + 1 - p):length(val))] ## remove init values

    out <- rbind(out,
                 data.table(value = val[-1:-aux],
                            id = s)) ## concenate data

  }

  out <- out[id != 0, ]

  return(data.table(date = x,
                    gauss = out[, value],
                    season = out[, id]))
}

#' Yule-Walker solver
#'
#' @param ACS vector of ACS values
#'
#' @keywords internal
#' @export
#'
#' @examples
#'
#' YW(rev(exp(seq(-1, 0, .1))))
#'
YW <- function(ACS) {

  p <- length(ACS) - 1

  P <- matrix(NA, p, p) ## cov matrix generation

  for (i in 1:p) {
    P[i, i:p] <- ACS[1:(p - i + 1)]
    P[i, 1:i] <- ACS[i:1]
  }

  rho <- matrix(ACS[2:(p + 1)], p, 1)

  return(solve(P, rho)) ## Yule-Walker
}
