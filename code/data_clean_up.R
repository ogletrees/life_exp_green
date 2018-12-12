# Date: 2018-12-12
# S Ogletree
# Description: Inital exploration of data for life expectancy project

library(tidyverse)
library(janitor)

# CDC data
cdc <- read.csv("../data/US_A.CSV", stringsAsFactors = F)

# NDVI data
flist <- list.files("E:/GoogleDrive/data_and_related/CDC_USLEEP/data/tract_ndvi_2015", full.names = T)
# first 12 have many cols, the rest are streamlined
f1 <- flist[1:12]
f2 <- flist[13:28]

ndvi_1 <- f1 %>% map_df(read.csv, stringsAsFactors = F) %>% select(system.index, geoid10, ndvi_mean, ndvi_sd, .geo)
ndvi_2 <- f2 %>% map_df(read.csv, stringsAsFactors = F)

ct_ndvi <- ndvi_1 %>% bind_rows(ndvi_2)
# there may habe been some tracts twice
ct_ndvi <- ct_ndvi %>% distinct(geoid10, .keep_all = T)

# tract id's moght be missing leading 0's
ct_ndvi$geoid10 <- str_pad(ct_ndvi$geoid10, width = 11, side = "left", pad = 0)
cdc$Tract.ID <- str_pad(cdc$Tract.ID, width = 11, side = "left", pad = 0)
cdc$STATE2KX <- str_pad(cdc$STATE2KX, width = 2, side = "left", pad = 0)

# Checking numbers --------------------------------------------------------

cdc %>% filter(Tract.ID %in% ct_ndvi$geoid10) %>% count()
# tract id's missing from NDVI data
miss_ndvi <- ct_ndvi %>% filter(!geoid10 %in% cdc$Tract.ID) %>% mutate(st_id = str_sub(geoid10, 1, 2), co_id = str_sub(geoid10, 3, 5))
# tract id's missing from CDC data
miss_cdc <- cdc %>% filter(!Tract.ID %in% ct_ndvi$geoid10)

# look at what is not matching up
tabyl(miss_cdc$STATE2KX)
tabyl(miss_ndvi$st_id)
# some places were excluded from the CDC data. Maine and Wisconsin; abridged life tables were calculated for all tracts with minimum pooled population sizes of 5,000

# combine what matches
df <- ct_ndvi %>% filter(geoid10 %in% cdc$Tract.ID) %>% 
  mutate(st_id = str_sub(geoid10, 1, 2), co_id = str_sub(geoid10, 3, 5)) %>% 
  left_join(cdc, by = c("geoid10"="Tract.ID"))

# simple correlation
cor.test(df$ndvi_mean, df$e.0.)
df %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point(alpha=0.2) + geom_smooth()
df %>% ggplot(aes(ndvi_mean, e.0.)) + geom_density_2d()
df %>% sample_n(500) %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point(alpha=0.2) + geom_smooth()
df %>% filter(e.0.> 90 & e.0.< 100) %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point(alpha=0.2) + geom_smooth()

hist(df$ndvi_mean)
hist(df$e.0.)
