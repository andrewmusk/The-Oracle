library(RSQLite)
db <- dbConnect(dbDriver("SQLite"), dbname = "user.db")
library(twitteR)
library(stringr)
library(httr)
library(dplyr)
setup_twitter_oauth("E7mQLq8gvmjEHVHCbYGdqDJXP","rpIgYX1629fgJCorODNijopOzigWEFlAR0qTHIGQikQG6HfkJg", access_token = "762565942249390081-sOzfcwpYwVFptmMbgJcjAJyguj9X0sV",access_secret = "0IFd6dyftZHAzt3I7FmUYQ8aHFDjpyFXobMq5E7d9xUwm")
results <- dbSendQuery(db, "SELECT * FROM tb_users;")
users <- dbFetch(results, n = -1)
head(users)


get_mean <- function(x) {
  username <- str_c("from:",x,sep="")
  user_tweets <- searchTwitter(username, n=100, lang="en")
  if(length(user_tweets)==0) stop
  user_id <- users[users$username==x,2]
  print(username)
  tweet.df <- twListToDF(user_tweets)
  tweet.df <- tweet.df[tweet.df$favoriteCount >5,]
  average = mean(tweet.df$favoriteCount)
  print(average)
  num_tweets = nrow(tweet.df)
  print(num_tweets)
  query <- paste("UPDATE tb_users SET favourite_mean =",average,", total_tweets = ",num_tweets,"WHERE user_id = ",user_id)
  print(query)
  results <- dbSendQuery(db,query)
}


user_list <- as.list(users$username)
lapply(user_list, get_mean)