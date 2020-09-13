#
# fast.ai collab tutorial
# https://docs.fast.ai/tutorial.collab
#

# load library
library(reticulate)

library(dplyr)
library(ggplot2)

# check which python is being used and check other python versions
# available. I found that if I used py_config() instead of py_discover_config()
# then it gives an error when I use the use_python command to point
# to a different python version
py_discover_config()
# set the python version to be used
use_python("/opt/anaconda3/bin/python", required = TRUE)
# check again which python is being used
py_discover_config()

py = import_main()
bi = import_builtins()

ftab = import("fastai.tabular.all")
fcol = import("fastai.collab")
pd = import("pandas")

path = fcol$untar_data(fcol$URLs$ML_100k)
path

datapath = paste0(path, "/u.data")
ratings = pd$read_csv(datapath, delimiter='\t', header=NULL,
                      usecols=c(0L,1L,2L), names=c('user','movie','rating'))
head(ratings)

datapath = paste0(path, "/u.item")
movies = pd$read_csv(datapath,  delimiter='|', encoding='latin-1',
                     usecols=c(0L,1L), names=c('movie','title'), header=NULL)
head(movies)

ratings2 = inner_join(ratings, movies, by = "movie")
head(ratings2)

dls = fcol$CollabDataLoaders$from_df(ratings2, item_name = "title", bs = 64L)

dls$show_batch()

learn = fcol$collab_learner(dls, n_factors=50L, y_range=c(0, 5.5))

learn$fit_one_cycle(5L, 5e-3, wd=0.1)

# get 1000 most rated movies
top_movies = ratings2 %>% count(title) %>% arrange(desc(n)) %>% slice(1:1000)
head(top_movies, 10)
top_movies2 = top_movies[["title"]]

movie_bias = learn$model$bias(top_movies2, is_item=TRUE)
movie_bias$shape
class(movie_bias)

movie_bias_r = py_to_r(movie_bias)
class(movie_bias_r)
py_run_string("print(r.movie_bias)")
movie_bias2 = movie_bias$numpy()

top_movies_wbias = tibble(title = top_movies2, bias = movie_bias2)
movies_avg_rating = ratings2 %>% mutate(as.character(title)) %>% group_by(title) %>% summarize(avg_rating = mean(rating, na.rm = TRUE))

top_movies_wbias = inner_join(top_movies_wbias, movies_avg_rating, by = "title")

# movies with worst bias
top_movies_wbias %>% arrange(bias) %>% print(n = 15)

# movies with best bias
top_movies_wbias %>% arrange(desc(bias)) %>% print(n = 15)

ggplot(top_movies_wbias) + 
  geom_point(aes(x = avg_rating, y = bias)) + theme_bw()

# Analyzing latent factors of movies

movie_w = learn$model$weight(top_movies2, is_item = TRUE)
movie_w$shape

movie_pca = movie_w$pca(3L)
movie_pca$shape

movie_pca2 = movie_pca$numpy()

movie_pca_df = data.frame(movie_pca2)
movie_pca_df = movie_pca_df %>% mutate(title = top_movies2)

# movies high/low in first PCA
movie_pca_df %>% select(X1, title) %>% arrange(desc(X1)) %>% slice(1:10)
movie_pca_df %>% select(X1, title) %>% arrange(X1) %>% slice(1:10)

# movies high/low in second PCA
movie_pca_df %>% select(X2, title) %>% arrange(desc(X2)) %>% slice(1:10)
movie_pca_df %>% select(X2, title) %>% arrange(X2) %>% slice(1:10)

# scatter plot for random 50 titles from top_movies data
movie_pca_dfsmp = movie_pca_df[sample(1:nrow(movie_pca_df), 50),]

ggplot(movie_pca_dfsmp) + geom_point(aes(x = X1, y = X2)) + 
  geom_text(aes(x = X1, y = X2, label = title)) + theme_bw()
