library(RSQLite)
db <- dbConnect(dbDriver("SQLite"), dbname = "user.db")
library(twitteR)

results <- dbSendQuery(db, "SELECT * FROM tb_users;")
users <- dbFetch(results, n = -1)
users

insert_tweets <- function(x)
{
  tweet.df <- twListToDF(x)
  query <- sprintf("INSERT INTO tb_tweets(tweet_id,user_id,favourites) VALUES (%s,%d,%d)", tweet.df$id,user_id,tweet.df$favoriteCount)
  results <- dbSendQuery(db,query)
}
get_tweets <- function(x) {
  username <- str_c("from:",x,sep="")
  user_tweets <- searchTwitter(username, n=50, lang="en", since=as.character(Sys.Date()))
  user_id <- users[users$username == x,2]
  lapply(user_tweets, insert_tweets(x))
}

tweets <- lapply(users$username, get_tweets(x))
