#Server script
options(stringsAsFactors = FALSE)

library(jsonlite)
library(ggplot2)
library(dplyr)

#build query
apiRoot <- "http://ws.audioscrobbler.com/2.0/"
method <- "user.getrecenttracks"
user <- read.csv("credentials.csv")$user
api_key <- read.csv("credentials.csv")$key
qformat <- "json"
limit <- 1000 #max

query <- paste0(apiRoot, 
               "?method=", method, 
               "&user=", user,
               "&api_key=", api_key,
               "&format=", qformat,
               "&limit=", limit)

#Connect to last.fm and plot top artists
jsonlite::fromJSON(txt = query, simplifyDataFrame = TRUE) %>%
  data.frame(track = dat$recenttracks$track$name,
                   artist = dat$recenttracks$track$artist$`#text`,
                   album = dat$recenttracks$track$album$`#text`,
                   dateListened = dat$recenttracks$track$date$`#text`) %>%
  group_by(artist) %>%
  summarise(plays = n()) %>%
  arrange(desc(plays)) %>%
  top_n(50) %>%
  mutate(artist = factor(artist, levels = artist[order(plays, decreasing = FALSE)])) %>%
  ggplot(aes(artist, plays)) + geom_bar(stat = "identity") +
  #theme(axis.text.x = element_text(angle = 45, hjust=1)) + 
  coord_flip() + 
  scale_y_continuous(breaks = seq(0,70,5))
