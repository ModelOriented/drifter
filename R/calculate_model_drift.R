#' Calculate Model Drift for comparison of models trained on new/old data
#'
#' This function calculates differences between PDP curves calculated for new/old models
#'
#' @param model_old model created on historical / `old`data
#' @param model_new model created on current / `new`data
#' @param data_new data frame with current / `new` data
#' @param predict_function function that takes two arguments: model and new data and returns numeric vector with predictions, by default it's `predict`
#' @param y_new true values of target variable for current / `new` data
#' @param max_obs if negative, them all observations are used for calculation of PDP, is positive, then only `max_obs` are used for calculation of PDP
#' @param scale scale parameter for calculation of scaled drift
#'
#' @return an object of a class `model_drift` (data.frame) with distances calculated based on Partial Dependency Plots
#' @importFrom dplyr filter group_by summarise
#' @importFrom tidyr spread
#' @importFrom stats predict sd
#' @importFrom ceterisParibus2 individual_variable_profile
#' @export
#'
#' @examples
#'  library("DALEX2")
#'  \dontrun{
#'  library("ranger")
#'  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
#'  model_old <- ranger(m2.price ~ ., data = apartments)
#'  model_new <- ranger(m2.price ~ ., data = apartments_test)
#'  calculate_model_drift(model_old, model_new,
#'                   apartments_test,
#'                   apartments_test$m2.price,
#'                   max_obs = 1000,
#'                   predict_function = predict_function)
#'
#'  predict_function <- function(m,x,...) predict(m, x, ..., probability=TRUE)$predictions[,1]
#'  data_old = HR[HR$gender == "male", -1]
#'  data_new = HR[HR$gender == "female", -1]
#'  model_old <- ranger(status ~ ., data = data_old, probability=TRUE)
#'  model_new <- ranger(status ~ ., data = data_new, probability=TRUE)
#'  calculate_model_drift(model_old, model_new,
#'                   HR_test,
#'                   HR_test$status == "fired",
#'                   max_obs = 1000,
#'                   predict_function = predict_function)
#' }
#'
calculate_model_drift <- function(model_old, model_new,
                                  data_new,
                                  y_new,
                                  predict_function = predict,
                                  max_obs = -1,
                                  scale = sd(y_new, na.rm = TRUE)) {
  #
  # test of model structure
  if (max_obs > 0) {
    data_new_small <- data_new[sample(1:nrow(data_new), max_obs),]
  } else {
    data_new_small <- data_new
  }

  prof_old <- individual_variable_profile(model_old,
                                          data = data_new,
                                          new_observation = data_new_small,
                                          label = "model_old",
                                          predict_function = predict_function)
  prof_new <- individual_variable_profile(model_new,
                                          data = data_new,
                                          new_observation = data_new_small,
                                          label = "model_new",
                                          predict_function = predict_function)
  # for all variables
  vars <- as.character(unique(prof_old$`_vname_`))

  df <- compare_two_profiles(prof_old, prof_new, vars, scale = scale)

  class(df) <- c("model_drift", "data.frame")
  df
}


#' Calculate Residual Drift for old model and new vs. old data
#'
#' @param model_old model created on historical / `old` data
#' @param data_old data frame with historical / `old` data
#' @param data_new data frame with current / `new` data
#' @param y_old true values of target variable for historical / `old` data
#' @param y_new true values of target variable for current / `new` data
#' @param predict_function function that takes two arguments: model and new data and returns numeric vector with predictions, by default it's `predict`
#' @param bins continuous variables are discretized to `bins` intervals of equal sizes
#'
#' @return an object of a class `covariate_drift` (data.frame) with inverse intersections distances calculated for residuals
#' @export
#'
#' @examples
#'  library("DALEX2")
#'  \dontrun{
#'  library("ranger")
#'  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
#'  model_old <- ranger(m2.price ~ ., data = apartments)
#'  calculate_residuals_drift(model_old,
#'                        apartments_test[1:4000,], apartments_test[4001:8000,],
#'                        apartments_test$m2.price[1:4000], apartments_test$m2.price[4001:8000],
#'                        predict_function = predict_function)
#'  calculate_residuals_drift(model_old,
#'                        apartments, apartments_test,
#'                        apartments$m2.price, apartments_test$m2.price,
#'                        predict_function = predict_function)
#' }
#'
calculate_residuals_drift <- function(model_old,
                                  data_old, data_new,
                                  y_old, y_new,
                                  predict_function = predict,
                                  bins = 20) {
  #
  # distance between residuals
  residuals_old <- y_old - predict_function(model_old, data_old)
  residuals_new <- y_new - predict_function(model_old, data_new)
  residuals_distance <- calculate_distance(residuals_old, residuals_new, bins = bins)

  df <- data.frame(variables = "Residuals",
                   drift = residuals_distance)
  class(df) <- c("covariate_drift", "data.frame")
  df
}


#' Calculates distance between two Ceteris Paribus Profiles
#'
#' This function calculates square root from mean square difference between Ceteris Paribus Profiles
#'
#' @param cpprofile_old Ceteris Paribus Profile for historical / `old` model
#' @param cpprofile_new Ceteris Paribus Profile for current / `new` model
#' @param variables variables for which drift should be calculated
#' @param scale scale parameter for calculation of scaled drift
#'
#' @return data frame with distances between Ceteris Paribus Profiles
#' @export
compare_two_profiles <- function(cpprofile_old, cpprofile_new, variables, scale = 1) {
  # clean check()
  `_label_` <- `_vname_` <- `_yhat_` <- avg <- x <- NULL

  distances <- numeric(length(variables))
  for (i in seq_along(variables)) {
    var <- variables[i]
    selected_var_old <- filter(cpprofile_old, `_vname_` == var)
    selected_var_new <- filter(cpprofile_new, `_vname_` == var)
    selected_var_old <- selected_var_old[,c(var, "_yhat_", "_label_")]
    selected_var_new <- selected_var_new[,c(var, "_yhat_", "_label_")]
    selected_var <- rbind(selected_var_old, selected_var_new)
    colnames(selected_var)[1] <- "x"

    selected_avg <- summarise(group_by(selected_var, x, `_label_`),
                              avg = mean(`_yhat_`, na.rm = TRUE))
    tmp <- spread(selected_avg, `_label_`, avg)
    distances[i] <- sqrt(mean((tmp$model_new - tmp$model_old)^2))
  }

  df <- data.frame(variables = variables,
                   drift = distances,
                   drift_scaled = distances/scale)
  df
}


#' Print Model Drift Data Frame
#'
#' @param x an object of the class `model_drift`
#' @param max_length length of the first column, by default 25
#' @param ... other arguments, currently ignored
#'
#' @return this function prints a data frame with a nicer format
#' @export
#'
#' @examples
#'  library("DALEX2")
#'  \dontrun{
#'  library("ranger")
#'  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
#'  model_old <- ranger(m2.price ~ ., data = apartments)
#'  model_new <- ranger(m2.price ~ ., data = apartments_test)
#'  calculate_model_drift(model_old, model_new,
#'                   apartments_test,
#'                   apartments_test$m2.price,
#'                   max_obs = 1000,
#'                   predict_function = predict_function)
#'
#'  predict_function <- function(m,x,...) predict(m, x, ..., probability=TRUE)$predictions[,1]
#'  data_old = HR[HR$gender == "male", -1]
#'  data_new = HR[HR$gender == "female", -1]
#'  model_old <- ranger(status ~ ., data = data_old, probability=TRUE)
#'  model_new <- ranger(status ~ ., data = data_new, probability=TRUE)
#'  calculate_model_drift(model_old, model_new,
#'                   HR_test,
#'                   HR_test$status == "fired",
#'                   max_obs = 1000,
#'                   predict_function = predict_function)
#'
#'  # plot it
#'  library("ceterisParibus2")
#'  prof_old <- individual_variable_profile(model_old,
#'                                      data = data_new,
#'                                      new_observation = data_new[1:1000,],
#'                                      label = "model_old",
#'                                      predict_function = predict_function)
#'  prof_new <- individual_variable_profile(model_new,
#'                                      data = data_new,
#'                                      new_observation = data_new[1:1000,],
#'                                      label = "model_new",
#'                                      predict_function = predict_function)
#'  plot(prof_old, prof_new,
#'       selected_variables = "age", aggregate_profiles = mean,
#'       show_observations = FALSE, color = "_label_")
#'
#' }
#'
print.model_drift <- function(x, max_length = 25, ...) {
  ntmp <- as.character(x$variables)
  numr <- sprintf("%3.2f", x$drift)
  numr2 <- paste0(substr(rep("     ", length(numr)), 1, 6 - nchar(numr)), numr)
  nums <- sprintf("%3.1f", round(100*x$drift_scaled,1))
  nums2 <- paste0(substr(rep("     ", length(nums)), 1, 6 - nchar(nums)), nums)
  nams <- sapply(ntmp, function(j) paste0(substr("                          ", 1,
                                                 pmax(max_length - nchar(j), 0)),
                                          substr(j, 1, max_length),
                                          " "))
  stars <- paste0(ifelse((x$drift_scaled > 0.1) & (x$drift_scaled < 0.2), ".", ""),
                  ifelse(x$drift_scaled > 0.2, "*", ""),
                  ifelse(x$drift_scaled > 0.3, "*", ""),
                  ifelse(x$drift_scaled > 0.4, "*", ""))

  cat("                  Variable    Shift  Scaled\n")
  cat("  -----------------------------------------------\n")
  cat("",paste0(nams, "  ", numr2, "  ", nums2, "  ", stars,"\n"))
  return(invisible(x))
}

