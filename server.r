#Server script
options(stringsAsFactors = FALSE)

library(jsonlite)
library(ggplot2)
library(scales)
library(dplyr)

#Connects to Last.fm and plots top n artists in specified period
getTopUserArtists <- function(user = read.csv("credentials.csv")$user,
                              from = "2016-01-01", 
                              to = Sys.Date(), #current date
                              ntop = 10, 
                              limit = 1000, 
                              api_key = read.csv("credentials.csv")$key){
  apiRoot <- "http://ws.audioscrobbler.com/2.0/"
  method <- "user.getrecenttracks"
  qformat <- "json"
  query <- paste0(apiRoot, 
                  "?method=", method, 
                  "&user=", user,
                  "&api_key=", api_key,
                  "&format=", qformat,
                  "&to=", as.numeric(as.POSIXct(to)),
                  "&from=", as.numeric(as.POSIXct(from)),
                  "&limit=", limit)
  pltObj <- jsonlite::fromJSON(txt = query, simplifyDataFrame = TRUE) %>%
    data.frame(track = .$recenttracks$track$name,
             artist = .$recenttracks$track$artist$`#text`,
             album = .$recenttracks$track$album$`#text`,
             dateListened = .$recenttracks$track$date$`#text`) %>%
    group_by(artist) %>%
    summarise(plays = n()) %>%
    arrange(desc(plays)) %>%
    top_n(ntop) %>%
    mutate(artist = factor(artist, levels = 
                             artist[order(plays, decreasing = FALSE)])) %>%
    ggplot(aes(artist, plays)) + geom_bar(stat = "identity") +
    coord_flip() + 
    scale_y_continuous(breaks = pretty_breaks(n=10))
  return(pltObj)
}

#Example
#getTopUserArtists(from = "2016-04-05", ntop = 15)
