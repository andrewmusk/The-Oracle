## Saturday evening attempt
library(rvest)
tech_people <- read_html("https://globerunner.com/top-100-tech-influencers-on-twitter/")
library(stringr)
theString <- tech_people %>% html_nodes("p") %>% .[[8]] %>% html_text() 
theString1 <- unlist(strsplit(theString, " "))
regex <- "(^|[^@\\w])@(\\w{1,15})\\b"
idx <- grep(regex, theString1, perl = T)
theString1[idx]
twitter_usernames <- gsub("\\n[0-9]+.", "", theString1[idx])

twitter_usernames
usernames.df <- as.data.frame(twitter_usernames)
usernames.df$user_id = 1:nrow(usernames.df)
usernames.df$mean = 0
usernames.df$total_tweets =0
library(readr)
write_csv(usernames.df,path="users.csv")

library(RSQLite)

db <- dbConnect(dbDriver("SQLite"), dbname = "users.db")

CREATE TABLE tb_users
(
username        VARCHAR(128),
user_id         INTEGER PRIMARY KEY AUTOINCREMENT,
favourite_mean  INTEGER,
total_tweets    INTEGER,
FOREIGN KEY (user_id) REFERENCES tb_tweets(user_id)
);

CREATE TABLE tb_tweets
(
tweet_id     VARCHAR(128) PRIMARY KEY,
user_id       INTEGER,
favourites    INTEGER
);

dbListTables(db)
dbReadTable(db, "tb_users")
results <- dbSendQuery(db, "SELECT * FROM tb_users;")
dbFetch(results, n = -1)