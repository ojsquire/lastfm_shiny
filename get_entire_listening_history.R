# Get entire listening history for a user (i.e. all scrobbles)
library(jsonlite)
library(ggplot2)
library(scales)
library(dplyr)
library(tidyr)

apiRoot <- "http://ws.audioscrobbler.com/2.0/"
method <- "user.getrecenttracks"
qformat <- "json"
user <- read.csv("top_artists_in_period/credentials.csv")$user
api_key <- read.csv("top_artists_in_period/credentials.csv")$key
limit <- 1000 # only displays 50 per page
page <- 1

query <- paste0(apiRoot, 
                "?method=", method, 
                "&user=", user,
                "&api_key=", api_key,
                "&format=", qformat,
                "&page=", page,
                "&limit=", limit)
dat <- fromJSON(txt = query, simplifyDataFrame = TRUE) #%>%
total_pages <- dat$recenttracks$`@attr`$totalPages

dat <- dat$recenttracks %>%
  as.data.frame %>%
  flatten

for (i in 2:total_pages){
  print(paste("importing page", i))
  query <- paste0(apiRoot, 
                  "?method=", method, 
                  "&user=", user,
                  "&api_key=", api_key,
                  "&format=", qformat,
                  "&page=", i,
                  "&limit=", limit)
  d1 <- fromJSON(txt = query, simplifyDataFrame = TRUE)
  d2 <- d1$recenttracks %>%
    as.data.frame %>%
    flatten

  dat <- rbind(dat, d2)
}

# Clean up, sort out images etc.
dat_out <- do.call(rbind.data.frame, dat$track.image) %>%
  mutate(index = rep(1:(n()/4), each=4)) %>%
  spread(size, `#text`) %>%
  rename(image_extralarge = extralarge) %>%
  rename(image_large = large) %>%
  rename(image_medium = medium) %>%
  rename(image_small = small) %>%  
  cbind(dat, .) %>% 
  select(-track.image, -index) %>%
  add_rownames("scrobble_id") %>%
  rename(track_name = track.name) %>%
  rename(streamable = track.streamable) %>%
  rename(track_mbid = track.mbid) %>%
  rename(url = track.url) %>%
  rename(user = X.attr.user) %>%
  rename(page = X.attr.page) %>%
  rename(per_page = X.attr.perPage) %>%
  rename(total_pages = X.attr.totalPages) %>%
  rename(total = X.attr.total) %>%
  rename(artist = `track.artist.#text`) %>%
  rename(artist_mbid = track.artist.mbid) %>%
  rename(album = `track.album.#text`) %>%
  rename(album_mbid = track.album.mbid) %>%
  select(-matches("track..attr.nowplaying"), everything()) %>%
  rename(play_timestamp_ux = track.date.uts) %>%
  rename(play_timestamp = `track.date.#text`) %>%
  select(scrobble_id, play_timestamp, track_name, artist, album, everything())

# Save data to disk
write.csv(dat_out, "my_scrobbles.csv", row.names = FALSE)
