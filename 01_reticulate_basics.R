
# load library
library(reticulate)

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

np = import("numpy")  # import numpy as np
LA = import("numpy.linalg") # from numpy import linalg

# Few examples using numpy

# using numpy sum and cumsum function
x = c(1, 2, 3, 4)
np$sum(x)
np$cumsum(x)

# eigen value/eigen vectors using numpy
# https://numpy.org/doc/stable/reference/generated/numpy.linalg.eig.html
A = matrix(c(1, -1, 1, 1), ncol = 2, byrow = TRUE)
A

eig_res = LA$eig(A)
# eigen values
eig_res[[1]]
# eigen vectors
eig_res[[2]]

# Few examples from scipy

# https://docs.scipy.org/doc/scipy/reference/tutorial/signal.html

misc = import("scipy.misc")
signal = import("scipy.signal")
plt = import("matplotlib.pyplot")

im1 = misc$ascent()
w = signal$gaussian(50, 10.0)
im1_new = signal$sepfir2d(im1, w, w)

# https://www.r-bloggers.com/creating-an-image-of-a-matrix-in-r-using-image/
rotate <- function(x) t(apply(x, 2, rev))
image(rotate(im1))

plt$figure()
plt$imshow(im1)
plt$gray()
plt$title("Original Image")
plt$show()

plt$figure()
plt$imshow(im1_new)
plt$gray()
plt$title("Filtered Image")
plt$show()

# Sympy examples
# https://docs.sympy.org/latest/tutorial/calculus.html
#
smp = import("sympy")

tmp = smp$symbols('x y z')
x = tmp[[1]]

op = import("operator")

# https://github.com/rstudio/reticulate/issues/170
"^.python.builtin.object" = function(a, b) {
  return(op$pow(a, b))
}

smp$diff(smp$cos(x), x)
smp$diff(smp$exp(x**2), x)

smp$integrate(smp$cos(x), x)

expr = smp$exp(smp$sin(x))
expr$series(x, 0L, 4L) # note need to pass integer using word L specifically

# object in R vs python

r_to_py(1) # R number to python float
r_to_py(1L) # R long integer to python int
r_to_py(c(1, 2, 3, 4)) # R vector to python list
r_to_py(list(c(1, 2, 3), "a", matrix(seq(1, 9), nrow = 3))) # R list to python list
r_to_py(list("a" = 1, "b" = 2, "c" = c(1, 2, 3))) # R names list to python dict



