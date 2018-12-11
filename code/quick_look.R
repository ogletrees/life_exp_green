library(tidyverse)

s01 <- read.csv("../Downloads/tract_15green_st_01.csv", stringsAsFactors = F)
str(s01)
s01 <- s01 %>% select(geoid10, ndvi_mean, ndvi_sd)
s01$geoid10 <- str_pad(s01$geoid10, 11, "left", 0)

d <- read.csv("E:/GoogleDrive/data_and_related/CDC_USLEEP/US_A.CSV", stringsAsFactors = F)
str(d)
d$Tract.ID <- str_pad(d$Tract.ID, 11, "left", 0)

s01 <- s01 %>% left_join(d, by = c("geoid10"="Tract.ID"))

sum(is.na(s01$e.0.))
s01 %>% filter(is.na(e.0.)) %>% View()

s01 %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point() + geom_smooth(method = "lm")

s04 <- read.csv("../Downloads/tract_15green_st_04.csv", stringsAsFactors = F)
s04 <- s04 %>% select(geoid10, ndvi_mean, ndvi_sd)
s04$geoid10 <- str_pad(s04$geoid10, 11, "left", 0)

s04 <- s04 %>% left_join(d, by = c("geoid10"="Tract.ID"))
s04 %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point() + geom_smooth(method = "lm")


s01$state <- "Alabama"
s04$state <- "Arizona"

stt <- s01 %>% bind_rows(s04)
stt %>% ggplot(aes(ndvi_mean, e.0.)) + geom_point() + geom_smooth() + facet_wrap(~state) + labs(y="Estimated life expectancy at birth", x="Mean NDVI for tract")
