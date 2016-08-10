library(RSQLite)
library(twitteR)
library(stringr)
library(httr)
db <- dbConnect(dbDriver("SQLite"), dbname = "user.db")
setup_twitter_oauth("E7mQLq8gvmjEHVHCbYGdqDJXP","rpIgYX1629fgJCorODNijopOzigWEFlAR0qTHIGQikQG6HfkJg", access_token = "762565942249390081-sOzfcwpYwVFptmMbgJcjAJyguj9X0sV",access_secret = "0IFd6dyftZHAzt3I7FmUYQ8aHFDjpyFXobMq5E7d9xUwm")
results <- dbSendQuery(db, "SELECT * FROM tb_users;")
users <- dbFetch(results, n = -1)
users

insert_tweets <- function(x,y)
{
  if(length(x)>0)
  {
    tweet.df <- twListToDF(x)
    print(tweet.df)
    query <- sprintf("('%s',%d,%d)", tweet.df$id,y,tweet.df$favoriteCount)
    query <- paste(query,collapse = ",")
    query <- paste("INSERT INTO tb_tweets(tweet_id,user_id,favourites) VALUES",query)
    print(query)
    results <- dbSendQuery(db,query)
    rm(tweet.df)
  }
}

get_tweets <- function(x) {
  username <- str_c("from:",x,sep="")
  print(username)
  user_tweets <- searchTwitter(username, n=100, lang="en", since=as.character(Sys.Date()))
  if(length(user_tweets)==0) stop
  user_id <- users[users$username == x,2]
  print(user_id)
  insert_tweets(user_tweets,user_id)
}

user_list <- as.list(users$username)
lapply(user_list, get_tweets)
lapply(test, class)
user_tweets[1]


results <- dbSendQuery(db,"SELECT *, tb_tweets.favourites/tb_users.favourite_mean AS Percentage FROM tb_tweets INNER JOIN tb_users ON tb_tweets.user_id == tb_users.user_id ORDER BY Percentage DESC")
all_tweets <- dbFetch(results,n=-1)
top_tweet_id <- as.character(all_tweets[1,1])
user_id <- all_tweets[1,2]
user <- users[users$user_id == user_id,1]
top_tweet_id %>% showStatus() %>% statusText() -> tweet_text
new_tweet <- str_c("from:",user," ",tweet_text)
if (nchar(new_tweet)>140)
{
  updateStatus(tweet_text)
} else {
  updateStatus(str_c("from:",user," ",tweet_text)) 
}


update_mean <- function() {
  query <- "SELECT user_id, COUNT(tweet_id) AS Number, SUM(favourites) AS Sum FROM tb_tweets GROUP BY user_id"
  results <- dbSendQuery(db,query)
  new_tweets <- dbFetch(results, n=-1)
  dbClearResult(results)
  apply(new_tweets,1,update_mean_sql)
}

update_mean_sql <- function(x) {
  print(x[2])
  query <- paste("SELECT favourite_mean FROM tb_users WHERE user_id =",x[1])
  results <- dbSendQuery(db,query)
  ave <- dbFetch(results, n=-1)
  dbClearResult(results)
  
  query <- paste("SELECT total_tweets FROM tb_users WHERE user_id =",x[1])
  no_results <- dbSendQuery(db,query)
  total <- dbFetch(results,n=-1)
  dbClearResult(no_results)
  
  
  all <- ave*total
  new_all <- all + x[3]
  new_total <- total + x[2]
  new_mean <- new_all/new_total
  
  query <- paste("UPDATE tb_users SET favourite_mean =",new_mean,", total_tweets = ",new_total,"WHERE user_id = ",x[1])
  print(query)
  dbSendQuery(db,query)
}

update_mean()

dbSendQuery(db,"DELETE FROM tb_tweets WHERE user_id>1")
