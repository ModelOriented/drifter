#' Calculate Covariate Drift for two data frames
#'
#' Here covariate drift is defined as Non-Intersection distance between two distributions.
#' More formally, $$d(P,Q) = 1 - sum_i min(P_i, Q_i)$$.
#' The larger the distance the more different are two distributions.
#'
#' @param data_old data frame with `old` data
#' @param data_new data frame with `new` data
#' @param bins continuous variables are discretized to `bins` intervals of equal sizes
#'
#' @return an object of a class `covariate_drift` (data.frame) with inverse intersections distances
#' @export
#'
#' @examples
#' library("DALEX2")
#' # here we do not have any drift
#' d <- calculate_covariate_drift(apartments, apartments_test)
#' d
#' # here we do have drift
#' d <- calculate_covariate_drift(dragons, dragons_test)
#' d
#'
calculate_covariate_drift <- function(data_old, data_new, bins = 20) {
  # variables present in both datasets
  joint_var <- intersect(colnames(data_new), colnames(data_old))

  # distances between variables
  distances <- numeric(length(joint_var))
  names(distances) <- joint_var

  for (i in seq_along(joint_var)) {
    distances[i] <- calculate_distance(data_old[,i], data_new[,i], bins = bins)
  }

  df <- data.frame(variables = names(distances),
                   drift = distances)
  class(df) <- c("covariate_drift", "data.frame")
  df
}

#' Calculate Inverse Intersection Distance
#'
#' @param variable_old variable from `old` data
#' @param variable_new variable from `new` data
#' @param bins continuous variables are discretized to `bins` intervals of equal size
#'
#' @return inverse intersection distance
#' @export
calculate_distance <- function(variable_old, variable_new, bins = 20) {
  if ("factor" %in% class(variable_old)) {
    after_cuts <- c(variable_old, variable_new)
  } else {
    after_cuts <- cut(rank(c(variable_old, variable_new)), bins)
  }

  after_cuts_table <- table(after_cuts, c(rep(1, length(variable_old)), rep(2, length(variable_new))))
  mat <- matrix(c(prop.table(after_cuts_table,2)), nrow = 2, byrow = TRUE)
  1 - sum(apply(mat, 2, min))
}

#' Print Covariate Drift Data Frame
#'
#' @param x an object of the class `covariate_drift`
#' @param max_length length of the first column, by default 25
#' @param ... other arguments, currently ignored
#'
#' @return this function prints a data frame with a nicer format
#' @export
#'
#' @examples
#' library("DALEX2")
#' # here we do not have any drift
#' d <- calculate_covariate_drift(apartments, apartments_test)
#' d
#' # here we do have drift
#' d <- calculate_covariate_drift(dragons, dragons_test)
#' d
#'
print.covariate_drift <- function(x, max_length = 25, ...) {
  ntmp <- as.character(x$variables)
  nums <- sprintf("%3.1f", round(100*x$drift,1))
  nums2 <- paste0(substr(rep("     ", length(nums)), 1, 6 - nchar(nums)), nums)
  nams <- sapply(ntmp, function(j) paste0(substr("                    ", 1,
                                                 pmax(max_length - nchar(j), 0)),
                                          substr(j, 1, max_length),
                                          " "))
  stars <- paste0(ifelse((x$drift > 0.1) & (x$drift < 0.2), ".", ""),
                  ifelse(x$drift > 0.2, "*", ""),
                  ifelse(x$drift > 0.3, "*", ""),
                  ifelse(x$drift > 0.4, "*", ""))

  cat("                  Variable  Shift\n")
  cat("  -------------------------------------\n")
  cat("",paste0(nams, nums2, "  ", stars,"\n"))
  return(invisible(x))
}
