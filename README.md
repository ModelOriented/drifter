# drifter: Concept Drift and Concept Shift Detection for Predictive Models

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/drifter)](https://cran.r-project.org/package=drifter)
[![Travis-CI Build Status](https://travis-ci.org/ModelOriented/drifter.svg?branch=master)](https://travis-ci.org/ModelOriented/drifter)
[![Coverage Status](https://img.shields.io/codecov/c/github/ModelOriented/drifter/master.svg)](https://codecov.io/github/ModelOriented/drifter?branch=master)


Machine learning models are often fitted and validated on historical data under silent assumption that data are stationary. The most popular techniques for validation (k-fold cross-validation, repeated cross-validation, and so on) test models on data with the same distribution as training data.

Yet, in many practical applications, deployed models are working in a changing environment. After some time, due to changes in the environment, model performance may degenerate, as model may be less reliable.

Concept drift refers to the change in the data distribution or in the relationships between variables over time. Think about model for energy consumption for a school, over time the school may be equipped with larger number of devices of with more power-efficient devices that may affect the model performance.

## Installation

To get started, install the newest version from GitHub.

```
devtools::install_github("ModelOriented/drifter")
```

To get help, see examples and details of the methodology, please refer to package website and vignettes.

## Implemented checks

* [calculate_covariate_drift](https://modeloriented.github.io/drifter/reference/calculate_covariate_drift.html) checks equality of unidimensional distributions $p(X_i)$ for two datasets (old vs new)
* [calculate_residuals_drift](https://modeloriented.github.io/drifter/reference/calculate_residuals_drift.html) checks equality residual distributions $p(X_i)$ for two models (old vs new)
* [calculate_model_drift](https://modeloriented.github.io/drifter/reference/calculate_model_drift.html) checks equality of PDP profiles for two models (old vs new)


