#
# fast.ai collab tutorial
# https://docs.fast.ai/tutorial.collab
#

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

ftab = import("fastai.tabular.all")
fcol = import("fastai.collab")
pd = import("pandas")

path = fcol$untar_data(fcol$URLs$ML_100k)
path

datapath = paste0(path, "/u.data")
ratings = pd$read_csv(datapath, delimiter='\t', header=NULL,
                      usecols=c(0L,1L,2L), names=c('user','movie','rating'))