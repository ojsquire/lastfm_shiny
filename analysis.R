# Analyse history (playground for now)
library(ggplot2)
library(scales)
library(dplyr)
library(tidyr)

# To do: 
# bring in data about album, so know e.g. when tracks released so can limit by
# that

# Data fetch
dat <- read.csv("my_scrobbles.csv")

# All artists (no pages!)
d1 <- dat %>%
  count(artist) %>%
  arrange(desc(n))

# Album count for an artist
dat %>%
  filter(artist == 'AFX') %>%
  count(album) %>%
  arrange(desc(n)) %>% View

# Album count for an artist
dat %>%
  filter(artist == 'Can') %>%
  count(album) %>%
  arrange(desc(n)) %>% View

dat %>%
  filter(grepl('Buck 65', artist)) %>%
  count(album) %>%
  arrange(desc(n)) %>% View

View(d1)

# Top tracks of 2016
dat %>%
  mutate(play_timestamp = as.POSIXct(strptime(play_timestamp, format = '%d %b %Y, %H:%M'))) %>% 
  filter(play_timestamp >= '2016-01-01') %>% 
  count(track_name) %>%
  arrange(desc(n)) %>%
  View

  
  
