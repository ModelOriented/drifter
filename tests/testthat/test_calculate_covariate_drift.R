context("Check calculate_covariate_drift() function")

test_that("Type of data in the explainer",{
  d <- calculate_covariate_drift(apartments, apartments_test)
  expect_true("covariate_drift" %in% class(d))
  expect_true(all(dim(d) == c(6,2)))
  expect_true(all(d[,2] <= 1))
  expect_true(all(d[,2] >= 0))
  expect_output(print(d), "m2.price")

})
