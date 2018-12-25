context("Check calculate_model_drift() function")

test_that("Type of data in the explainer",{
  library("DALEX2")
  library("ranger")
  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
  model_old <- ranger(m2.price ~ ., data = apartments)
  model_new <- ranger(m2.price ~ ., data = apartments_test)
  d <- calculate_model_drift(model_old, model_new,
                     apartments_test,
                     apartments_test$m2.price,
                     max_obs = 1000,
                     predict_function = predict_function)
  expect_true("model_drift" %in% class(d))
  expect_true(all(dim(d) == c(6,3)))
})
