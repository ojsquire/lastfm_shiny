#Server script
library(shiny)

shinyServer(function(input, output) {
  options(stringsAsFactors = FALSE)
  
  library(jsonlite)
  library(ggplot2)
  library(scales)
  library(dplyr)
  
#Connects to Last.fm and plots top n artists in specified period
getTopUserArtists <- function(user = read.csv("top_tracks_of_year_released_in_year/credentials.csv")$user,
                              from = "2015", 
                              to = Sys.Date(), #current date
                              n = 10, 
                              limit = 1000, 
                              api_key = read.csv("top_tracks_of_year_released_in_year/credentials.csv")$key,
                              top = TRUE){
  apiRoot <- "http://ws.audioscrobbler.com/2.0/"
  #method <- "user.getrecenttracks"
  method <- "user.getWeeklyTrackChart"
  qformat <- "json"
  query <- paste0(apiRoot, 
                  "?method=", method, 
                  "&user=", user,
                  "&api_key=", api_key,
                  "&format=", qformat,
                  "&to=", as.numeric(as.POSIXct(to)),
                  "&from=", as.numeric(as.POSIXct(from)),
                  "&limit=", limit)
  dat <- fromJSON(txt = query, simplifyDataFrame = TRUE) #%>%
    # data.frame(track = .$recenttracks$track$name,
    #          artist = .$recenttracks$track$artist$`#text`,
    #          album = .$recenttracks$track$album$`#text`,
    #          dateListened = .$recenttracks$track$date$`#text`) %>%
    # group_by(artist) %>%
    # summarise(plays = n()) %>%
    # {if(top){
    #   top_n(., n, plays)
    # } else{
    #   arrange(., plays)[1:n,]
    # }} %>%
    # mutate(., artist = factor(artist, levels = 
    #                             artist[order(plays)])) 
  return(dat)
}  

#Really we want top track from top 10 albums (!) - can query trackInfo to get that...

x <- getTopUserArtists(from = "2016-01-01", to = "2016-05-05")
View(x$weeklytrackchart$track[, c("artist", "name", "playcount")])

x <- getTopUserArtists(from = input$fromDate, n = input$nTopArtists)

output$topUserArtists <- renderPlot({
  x <- getTopUserArtists(from = input$fromDate, n = input$nTopArtists)
    ggplot(x, aes(artist, plays)) + geom_bar(stat = "identity") +
    coord_flip() + 
    scale_y_continuous(breaks = pretty_breaks(n=10))
})
# #Note: top = FALSE returns least listened to artists :-D
# getTopUserArtists(from = "2016-03-05", n = 20, top = FALSE)
})
