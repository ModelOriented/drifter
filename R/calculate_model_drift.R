#' Calculate Model Drift for new/old data sets and models
#'
#' @param model_old model created on historical / `old`data
#' @param model_new model created on current / `new`data
#' @param data_old data frame with `old` data
#' @param data_new data frame with `new` data
#' @param predict_function unction that takes two arguments: model and new data and returns numeric vector with predictions, by default it's `predict`
#'
#' @return an object of a class `model_drift` (data.frame) with distances calculated based on Partial Dependency Plots
#' @importFrom dplyr filter group_by summarise
#' @importFrom tidyr spread
#' @importFrom ceterisParibus2 individual_variable_profile
#' @export
#'
#' @examples
calculate_model_drift <- function(model_old, model_new = NULL,
                                  data_old, data_new,
                                  y_old, y_new,
                                  predict_function = predict) {
  data_old_small <- data_old[sample(1:nrow(data_old), 500),]
  data_new_small <- data_new[sample(1:nrow(data_new), 500),]
  #
  # compare old model on old vs new data
  prof_old <- individual_variable_profile(model_old,
                                          data = data_old,
                                          new_observation = data_old_small,
                                          label = "model_old",
                                          predict_function = predict_function)
  prof_new <- individual_variable_profile(model_old,
                                          data = data_old,
                                          new_observation = data_new_small,
                                          label = "model_new",
                                          predict_function = predict_function)

  # for all variables
  vars <- as.character(unique(prof_old$`_vname_`))

  df <- compare_two_profiles(prof_old, prof_new, vars, scale = sd(y_old, na.rm = TRUE))
  #
  # compare old vs new model on new data
  if (!is.null(model_new)) {
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
    df_model <- compare_two_profiles(prof_old, prof_new, vars, scale = sd(y_new, na.rm = TRUE))
    df <- cbind(df, df_model)
  }

  class(df) <- c("model_drift", "data.frame")
  df
}


compare_two_profiles <- function(cpprofile_old, cpprofile_new, variables, scale = 1) {
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

