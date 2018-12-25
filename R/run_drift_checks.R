#' This function executes all tests for drift between two datasets / models
#'
#' Currently three checks are implemented, covariate drift, residual drift and model drift.
#'
#' @param model_old model created on historical / `old`data
#' @param model_new model created on current / `new`data
#' @param data_old data frame with historical / `old` data
#' @param data_new data frame with current / `new` data
#' @param y_old true values of target variable for historical / `old` data
#' @param y_new true values of target variable for current / `new` data
#' @param predict_function function that takes two arguments: model and new data and returns numeric vector with predictions, by default it's `predict`
#' @param max_obs if negative, them all observations are used for calculation of PDP, is positive, then only `max_obs` are used for calculation of PDP
#' @param bins continuous variables are discretized to `bins` intervals of equal sizes
#' @param scale scale parameter for calculation of scaled drift
#'
#' @return This function is executed for its side effects, all checks are being printed on the screen. Additionaly it returns list with particualr checks.
#' @export
#'
#' @examples
#'  library("DALEX2")
#'  \dontrun{
#'  library("ranger")
#'  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
#'  model_old <- ranger(m2.price ~ ., data = apartments)
#'  model_new <- ranger(m2.price ~ ., data = apartments_test)
#'  run_drift_checks(model_old, model_new,
#'                   apartments, apartments_test,
#'                   apartments$m2.price, apartments_test$m2.price,
#'                   predict_function = predict_function)
#' }
run_drift_checks <- function(model_old, model_new,
                             data_old, data_new,
                             y_old, y_new,
                             predict_function = predict,
                             max_obs = 500,
                             bins = 20,
                             scale = sd(y_new, na.rm = TRUE)) {

  # check covariate drift
  dc <- calculate_covariate_drift(data_old, data_new, bins = bins)
  cat("   -------------------------------------\n")
  print(dc)

  # check residual drift
  dr <- calculate_residuals_drift(model_old,
                            data_old, data_new,
                            y_old, y_new,
                            predict_function = predict_function,
                            bins = bins)
  cat("   -------------------------------------\n")
  print(dr)

  # check model drift
  dm <- calculate_model_drift(model_old, model_new,
                        data_new,
                        y_new,
                        predict_function = predict_function,
                        max_obs = max_obs,
                        scale = scale)
  cat("   -----------------------------------------------\n")
  print(dm)
  invisible(list(covariate_drift = dc,
                 residual_drift = dr,
                 model_drift = dm))
}
