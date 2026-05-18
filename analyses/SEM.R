# ── Summary statistics helpers ─────────────────────────────────────────────────
# Provides three functions for computing grouped summary statistics,
# including within-subject error correction (Morey 2008).
#
# Source this file at the top of any analysis script with:
#   source(here("SEM.R"))
#
# Functions:
#   summarySE()         – mean, SD, SE, and CI by group
#   normDataWithin()    – normalise data within subjects (used by summarySEwithin)
#   summarySEwithin()   – within-subject corrected SE and CI (Morey 2008)

library(plyr)

# ── summarySE ─────────────────────────────────────────────────────────────────
# Returns count, mean, SD, SE, and CI for a given variable, optionally by group.
#
# Arguments:
#   data          : a data frame
#   measurevar    : name of the column to summarise (string)
#   groupvars     : character vector of grouping column names (or NULL)
#   na.rm         : whether to ignore NAs (default FALSE)
#   conf.interval : confidence level (default 0.95)
#   .drop         : whether to drop empty factor combinations (default TRUE)

summarySE <- function(data = NULL, measurevar, groupvars = NULL, na.rm = FALSE,
                      conf.interval = 0.95, .drop = TRUE) {

  # Version of length() that handles NAs
  length2 <- function(x, na.rm = FALSE) {
    if (na.rm) sum(!is.na(x)) else length(x)
  }

  datac <- ddply(data, groupvars, .drop = .drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm = na.rm),
                     mean = mean(xx[[col]], na.rm = na.rm),
                     sd   = sd(xx[[col]], na.rm = na.rm))
                 },
                 measurevar)

  datac <- plyr::rename(datac, c("mean" = measurevar))
  datac$se <- datac$sd / sqrt(datac$N)

  ciMult    <- qt(conf.interval / 2 + 0.5, datac$N - 1)
  datac$ci  <- datac$se * ciMult

  return(datac)
}


# ── normDataWithin ────────────────────────────────────────────────────────────
# Normalises data within subjects so each subject has the same grand mean,
# within each between-subjects group. Used internally by summarySEwithin().
#
# Arguments:
#   data        : a data frame
#   idvar       : column identifying each subject
#   measurevar  : column containing the variable to normalise
#   betweenvars : character vector of between-subjects grouping columns (or NULL)
#   na.rm       : whether to ignore NAs (default FALSE)
#   .drop       : whether to drop empty factor combinations (default TRUE)

normDataWithin <- function(data = NULL, idvar, measurevar, betweenvars = NULL,
                           na.rm = FALSE, .drop = TRUE) {

  data.subjMean <- ddply(data, c(idvar, betweenvars), .drop = .drop,
                         .fun = function(xx, col, na.rm) {
                           c(subjMean = mean(xx[, col], na.rm = na.rm))
                         },
                         measurevar,
                         na.rm)

  data              <- merge(data, data.subjMean)
  measureNormedVar  <- paste0(measurevar, "_norm")
  data[, measureNormedVar] <- data[, measurevar] - data[, "subjMean"] +
                              mean(data[, measurevar], na.rm = na.rm)
  data$subjMean     <- NULL

  return(data)
}


# ── summarySEwithin ───────────────────────────────────────────────────────────
# Within-subject corrected summary statistics (Morey 2008).
# Returns un-normed mean, normed mean, SD, SE, and CI.
# Works correctly even when there are no within-subject variables.
#
# Arguments:
#   data          : a data frame
#   measurevar    : column containing the variable to summarise
#   betweenvars   : character vector of between-subjects grouping columns (or NULL)
#   withinvars    : character vector of within-subjects grouping columns (or NULL)
#   idvar         : column identifying each subject
#   na.rm         : whether to ignore NAs (default FALSE)
#   conf.interval : confidence level (default 0.95)
#   .drop         : whether to drop empty factor combinations (default TRUE)

summarySEwithin <- function(data = NULL, measurevar, betweenvars = NULL,
                            withinvars = NULL, idvar = NULL, na.rm = FALSE,
                            conf.interval = 0.95, .drop = TRUE) {

  # Ensure grouping variables are factors
  factorvars <- vapply(data[, c(betweenvars, withinvars), drop = FALSE],
                       FUN = is.factor, FUN.VALUE = logical(1))

  if (!all(factorvars)) {
    nonfactorvars <- names(factorvars)[!factorvars]
    message("Automatically converting the following non-factors to factors: ",
            paste(nonfactorvars, collapse = ", "))
    data[nonfactorvars] <- lapply(data[nonfactorvars], factor)
  }

  # Un-normed means
  datac <- summarySE(data, measurevar,
                     groupvars = c(betweenvars, withinvars),
                     na.rm = na.rm, conf.interval = conf.interval, .drop = .drop)
  datac$sd <- NULL
  datac$se <- NULL
  datac$ci <- NULL

  # Normed data
  ndata       <- normDataWithin(data, idvar, measurevar, betweenvars, na.rm, .drop = .drop)
  measurevar_n <- paste0(measurevar, "_norm")

  ndatac <- summarySE(ndata, measurevar_n,
                      groupvars = c(betweenvars, withinvars),
                      na.rm = na.rm, conf.interval = conf.interval, .drop = .drop)

  # Morey (2008) correction factor
  nWithinGroups    <- prod(vapply(ndatac[, withinvars, drop = FALSE],
                                  FUN = nlevels, FUN.VALUE = numeric(1)))
  correctionFactor <- sqrt(nWithinGroups / (nWithinGroups - 1))

  ndatac$sd <- ndatac$sd * correctionFactor
  ndatac$se <- ndatac$se * correctionFactor
  ndatac$ci <- ndatac$ci * correctionFactor

  merge(datac, ndatac)
}
