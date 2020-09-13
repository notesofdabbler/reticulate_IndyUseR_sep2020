
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

wd = import("norvig_words")

TEXT = readLines("https://raw.githubusercontent.com/norvig/pytudes/master/data/text/big.txt")
TEXT = paste(TEXT, collapse = " ")
sum(nchar(TEXT))

wd$tokens('This is: "A test".')

WORDS = wd$tokens(TEXT)
length(WORDS)
wd$sentence(WORDS[1:10])

BAG = wd$Bag(WORDS)
common_words = BAG$most_common(20L)
common_words_L = lapply(common_words, function(x) list(word = x[[1]], count = x[[2]]))
common_words_df = bind_rows(common_words_L)
common_words_df

Pword = wd$Bag(WORDS)
Pword("the")
Pword["the"]

wd$splits("word")

wd$segment("choosespain", tuple(WORDS))
wd$segment("speedofart", tuple(WORDS))
wd$segment("smallandinsignificant", tuple(WORDS))

decl = paste0("wheninthecourseofhumaneventsitbecomesnecessaryforonepeoplet",
              "odissolvethepoliticalbandswhichhaveconnectedthemwithanothe",
              "andtoassumeamongthepowersoftheearththeseparateandequalstati",
              "ontowhichthelawsofnatureandofnaturesgodentitlethem", sep = "")
wd$sentence(wd$segment(decl, tuple(WORDS)))
