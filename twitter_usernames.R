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
