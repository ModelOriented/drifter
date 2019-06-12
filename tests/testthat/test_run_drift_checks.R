context("Check check_drift() function")

test_that("Length of all checks",{
  library("DALEX")
  library("ranger")
  predict_function <- function(m,x,...) predict(m, x, ...)$predictions
  model_old <- ranger(m2.price ~ ., data = apartments)
  model_new <- ranger(m2.price ~ ., data = apartments_test)
  res <- check_drift(model_old, model_new,
                   apartments, apartments_test,
                   apartments$m2.price, apartments_test$m2.price,
                   predict_function = predict_function)

  expect_true(length(res) == 3)
  expect_output(print(res), "m2.price")
})
