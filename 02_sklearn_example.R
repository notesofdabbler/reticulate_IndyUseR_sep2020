#
#  Example from sklearn documentation - Gaussian Process Classification
#  https://scikit-learn.org/stable/auto_examples/gaussian_process/plot_gpc_xor.html#sphx-glr-auto-examples-gaussian-process-plot-gpc-xor-py
#

# load library
library(reticulate)

library(ggplot2)
library(dplyr)

# check which python is being used and check other python versions
# available. I found that if I used py_config() instead of py_discover_config()
# then it gives an error when I use the use_python command to point
# to a different python version
py_discover_config()
# set the python version to be used
use_python("/opt/anaconda3/bin/python", required = TRUE)
# check again which python is being used
py_discover_config()

# importing python modules
py = import_main()
bi = import_builtins()

np = import("numpy")
skg = import("sklearn.gaussian_process")
skgk = import("sklearn.gaussian_process.kernels")

set.seed(1234)
xsim = rnorm(400)
X = matrix(xsim, ncol = 2)
xprod = X[,1]*X[,2]
y = ifelse(xprod > 0, 1, 0)

df = data.frame(X)
df$y = y
ggplot(df) + geom_point(aes(x = X1, y = X2, color = factor(y))) + theme_bw()

# kernel 1
clf = skg$GaussianProcessClassifier(kernel = 1.0*skgk$RBF(length_scale = 1.0), warm_start = TRUE)$fit(X, y)

Xfull = expand.grid(X1 = seq(-3, 3, length = 50), X2 = seq(-3, 3, length = 50))
yfull = clf$predict_proba(Xfull)[, 1]

dfpred = bind_cols(Xfull, yfull)
names(dfpred) = c("X1", "X2", "y")

ggplot() + geom_contour_filled(data = dfpred, aes(x = X1, y = X2, z = y)) + 
  geom_point(data = df, aes(x = X1, y = X2, color = factor(y)))

clf$kernel_
clf$log_marginal_likelihood(clf$kernel_$theta)

# kernel 2
clf = skg$GaussianProcessClassifier(kernel = 1.0 * skgk$DotProduct(sigma_0=1.0)**2, warm_start = TRUE)$fit(X, y)

yfull = clf$predict_proba(Xfull)[, 1]
Z = matrix(yfull, ncol = 50, byrow = TRUE)

filled.contour(seq(-3, 3, length = 50), seq(-3, 3, length = 50), Z)

dfpred = bind_cols(Xfull, yfull)
names(dfpred) = c("X1", "X2", "y")

ggplot() + geom_contour_filled(data = dfpred, aes(x = X1, y = X2, z = y)) + 
    geom_point(data = df, aes(x = X1, y = X2, color = factor(y)))
