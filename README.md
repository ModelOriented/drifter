# drifter: Concept Drift and Concept Shift Detection for Predictive Models

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/drifter)](https://cran.r-project.org/package=drifter)
[![Travis-CI Build Status](https://travis-ci.org/ModelOriented/drifter.svg?branch=master)](https://travis-ci.org/ModelOriented/drifter)
[![Coverage Status](https://img.shields.io/codecov/c/github/ModelOriented/drifter/master.svg)](https://codecov.io/github/ModelOriented/drifter?branch=master)
[https://img.shields.io/badge/DrWhy-eXtrAI-4378bf?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAA6CAYAAADybArcAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2JJREFUeNrsWj2LE1EUnQ0rWihOIaiVwbWO0SaVMPgHNt1usUUKkS3HQrQcrVawmO3EKlhoyvgHZGQtVtlisJBFV4g2rthEtLGK98J55BEzmXkf84U5cMjXvMmceffde957szKZTJwUeMQRWFmsLvitSfSJY3x2iYH0uRZCgjkXzsL6xCFeqwUOLYldYp/ozXwvk38bphxTOMWbNgT0FBr7aNOsipDbxCOiq3ECF2LaZQtpUHR9JK4RPxE3FSNzjPHilj1EGtL7c8QXxJjYcmqGxpzvrhLfITu5dRbCOElcRxHcqbMQgbPEe6juOmhjDDG7ZQrRBYdkiItnd9DDd32IK9Si6CKQhMj+TLgCIcyq3bEppAvyBUcL0nUAuxMiQ4ZVCa3TSAgu7nSUoc0Ix8bopXZVxsh14rZGuo6knixdyG/iCWKH+JU4qGL6VcUZ4gbxh4bdqWT6FXbnc1F2p5Hz+S/D7mwYnKOHTNgsU4iwOxcNXMEYtceXalQhBdGGKwgkAaJo+hAXItv1qywkyRUIxAi1ruThoqJCKwuaKIwR7nza0tMQgjyIdk2FbCI7mYYSJ4PDjK5gtgdZiK8rpIVuZhEXDIXwGDiF6cKRRv0Z6YSWi259g5mkbawh7vdV64+KkB10/zoqeJ7puoObNbAtZICuP19gAhB255h4y5aQIgXM+++tsi1K7U3jUkiZQv4YtjddN/NsCOH5xgMDV/AN2dDE1vBroGsav6Nw3XfUF++40D0zKKiyO+4Jd6wq5BfxlXwCxQtg8TcNCqqw8sE/xhI7T1kQE1sJO1hp2CceT/RxmLZLlrVH7hIfG4yljkHbL8TnxIeLDsoq5KCEjPpTsum1rSO7znRZNROqNtV9jQEdqza0IcTGrhan823UBe3KztPLO4hJVQGhY7YAza7gLfGJiQiRfme3mufBS9lj1wFvid9A+8DG9rQ8d+ZCdw2xmuRrhtKyzEgzjB4RrxD3bA2u1YS1Iw9rRxw6l5zpcyixo78FYOIKlEIriRxCYcqTEWn4kOAKHFuhlSVr9Szcr6fE98uJ1VLIfyzkpeEsL8oj/eqg60xXxrPM/ObO8vJOv6rkqj+eSb9+3k/e5TFGQoTMbg6uIBErGZ77NUFTMoN9x9LjGmUIkW1+rs8L/xVgALYvCxtbIHugAAAAAElFTkSuQmCC](http://drwhy.ai/#eXtraAI)

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

* [calculate_covariate_drift](https://modeloriented.github.io/drifter/reference/calculate_covariate_drift.html) checks distance between unidimensional distributions $p(X_i)$ for two datasets (old vs new)
* [calculate_residuals_drift](https://modeloriented.github.io/drifter/reference/calculate_residuals_drift.html) checks distance between residual distributions $p(X_i)$ for two models (old vs new)
* [calculate_model_drift](https://modeloriented.github.io/drifter/reference/calculate_model_drift.html) checks distance between PDP profiles for two models (old vs new)
* [check_drift](https://modeloriented.github.io/drifter/reference/check_drift.html) executes all checks against drift.


