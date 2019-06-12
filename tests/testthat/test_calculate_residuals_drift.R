context("Check calculate_covariate_drift() function")

test_that("Type of data in the explainer",{
  library("DALEX")
  library("ranger")
  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
  model_old <- ranger(m2.price ~ ., data = apartments)
  d <- calculate_residuals_drift(model_old,
                      apartments_test[1:4000,], apartments_test[4001:8000,],
                      apartments_test$m2.price[1:4000], apartments_test$m2.price[4001:8000],
                      predict_function = predict_function)

  expect_true("covariate_drift" %in% class(d))
  expect_true(all(dim(d) == c(1,2)))
  expect_true(d[,2] <= 1)
  expect_true(d[,2] >= 0)
})
