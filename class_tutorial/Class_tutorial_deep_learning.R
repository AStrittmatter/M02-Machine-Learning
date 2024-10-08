### Lab: Deep Learning

## In this version of the Ch10 lab, we  use the `luz` package, which interfaces to the
## `torch` package which in turn links to efficient
## `C++` code in the LibTorch library.

## This version of the lab was produced by Daniel Falbel and Sigrid
## Keydana, both data scientists at Rstudio where these packages were
## produced.

## An advantage over our original `keras` implementation is that this
## version does not require a separate `python` installation.

##########################################
## Single Layer Network on Hitters Data ##
##########################################

## Load various packages
library(ISLR2)
library(glmnet)
library(torch)
library(luz) # high-level interface for torch
library(torchvision) # for datasets and image transformation
library(torchdatasets) # for datasets we are going to use
library(zeallot)
library(ggplot2)
library(grf)

## Loading the dataset
## We use the example data with baseball player salaries from lecture 4
Gitters <- na.omit(Hitters)
n <- nrow(Gitters)
print(paste("Number of observations:", n))

## Define tes sample
set.seed(13)
ntest <- trunc(n / 3)
testid <- sample(1:n, ntest)


#######################
## Linear Regression ##
#######################
lfit <- lm(Salary ~ ., data = Gitters[-testid, ])
summary(lfit)
lpred <- predict(lfit, Gitters[testid, ])
print(paste("MAE:", mean(abs(Gitters$Salary[testid] - lpred))))

## Dafine y and x as matrix
x <- scale(model.matrix(Salary ~ . - 1, data = Gitters))
print(paste("Number of controls:", ncol(x)))
y <- Gitters$Salary

############
## Lasso ##
###########
cvfit <- cv.glmnet(x[-testid, ], y[-testid], type.measure = "mae")
coef(cvfit)
cpred <- predict(cvfit, x[testid, ], s = "lambda.min")
print(paste("MAE:",mean(abs(y[testid] - cpred))))

###################
## Random Forest ##
###################
forest <- regression_forest(x[-testid, ], y[-testid])
fpred <- predict(forest, x[testid, ])
print(paste("MAE:",mean(abs(y[testid] - fpred$prediction))))

####################
## Neural Network ##
####################

torch_manual_seed(13)

# single hidden layer
# 10 hidden units
# ReLU activation function
# dropout layer, in which a random 40% of the 10 activations from the 
# previous layer are set to zero during each iteration of the stochastic 
# gradient descent algorithm
# One output
# linear output function
modnn <- nn_module(
  initialize = function(input_size) {
    self$hidden <- nn_linear(input_size, 10)
    self$activation <- nn_relu()
    self$dropout <- nn_dropout(0.4)
    self$output <- nn_linear(10, 1)
  },
  forward = function(x) {
    x %>%
      self$hidden() %>%
      self$activation() %>%
      self$dropout() %>%
      self$output()
  }
)

# Specify optimisation algorithm
# Here mse loss
modnn <- modnn %>%
  setup(
    loss = nn_mse_loss(),
    optimizer = optim_rmsprop,
    metrics = list(luz_metric_mae())
  ) %>%
  set_hparams(input_size = ncol(x))

# Train the neural network in 1500 iterations
fitted <- modnn %>%
  fit(
    data = list(x[-testid, ], matrix(y[-testid], ncol = 1)),
    valid_data = list(x[testid, ], matrix(y[testid], ncol = 1)),
    epochs = 1500
  )
#plot(fitted)


npred <- predict(fitted, x[testid, ])
mean(abs(y[testid] - npred))
