library(RSQLite)
db <- dbConnect(dbDriver("SQLite"), dbname = "user.db")
library(twitteR)
library(stringr)
library(httr)
setup_twitter_oauth("E7mQLq8gvmjEHVHCbYGdqDJXP","rpIgYX1629fgJCorODNijopOzigWEFlAR0qTHIGQikQG6HfkJg", access_token = "762565942249390081-sOzfcwpYwVFptmMbgJcjAJyguj9X0sV",access_secret = "0IFd6dyftZHAzt3I7FmUYQ8aHFDjpyFXobMq5E7d9xUwm")
results <- dbSendQuery(db, "SELECT * FROM tb_users;")
users <- dbFetch(results, n = -1)
users

insert_tweets <- function(x,y)
{
  tweet.df <- twListToDF(x)
  #print(tweet.df)
  query <- sprintf("INSERT INTO tb_tweets(tweet_id,user_id,favourites) VALUES ('%s',%d,%d)", tweet.df$id,y,tweet.df$favoriteCount)
  print(query)
  #results <- dbSendQuery(db,query)
  rm(tweet.df)
}
get_tweets <- function(x) {
  username <- str_c("from:",x,sep="")
  user_tweets <- searchTwitter(username, n=50, lang="en", since=as.character(Sys.Date()))
  user_id <- users[users$username == x,2]
  insert_tweets(user_tweets,user_id)
}

#I am having issues with the lapply above. Particularly when I run lapply(user_tweets, insert_tweets) with a set of sample user_tweets
# it gives me the error that they are not the same length however when I run it manually, it works perfectly fine. 


tweets <- lapply(users$username, get_tweets)
tweets <- lapply(users$username, class)
user_tweets[1]


results <- dbSendQuery(db,"SELECT *, tb_tweets.favourites/tb_users.favourite_mean AS Percentage FROM tb_tweets INNER JOIN tb_users ON tb_tweets.user_id == tb_users.user_id ORDER BY Percentage DESC")
all_tweets <- dbFetch(results,n=-1)
top_tweet_id <- all_tweets[1,1]

updateStatus("The top tweet of the day is:", inReplyTo = showStatus(top_tweet_id))#this is not working because of the inreplyto. For some reason this method doesn't work

update_mean <- function(x) {
  
  }
#write the function that calculates the the new mean based on the new day's tweets. This has to be 
# weighted using the total number of tweets 
