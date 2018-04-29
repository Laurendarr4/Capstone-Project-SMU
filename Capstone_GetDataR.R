
###Capstone Project
##Dallas Open Data-Police Incidents
#3/31/2018

###Scrape data using Socrata API
## Install the required package with:
## install.packages("RSocrata")

library("RSocrata")
library(tidyr)
library(stringr)
library(readr)

#Use soDA URL to access Incident Data; set limit on number of rows per page to 500 for now
url= "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$limit=500&$offset=0"

df <- read.socrata(url, app_token = NULL, email= NULL, password= NULL)

#Check for correct data loaded
head(df)

# Take the Point and () out of the location1 data
# Seperate Point and ()
df$latlon <- gsub(".*\\((.*)\\).*","\\1", df$location1)
# Spilt out into list 2 columns
LatLong <- str_split_fixed((df$latlon)," ",2)
# Name columns in list
colnames(LatLong) <- c("Latitue", "Longitude")
# Covert into dataframe
df_LatLong <-as.data.frame(LatLong)
# Bring into current frame
# Convert to Numeric
df$Latitude <- as.numeric(df_LatLong$Latitue)
df$Longitude <- as.numeric(df_LatLong$Longitude)

# Does not show up, needs to be merged some how or another method developed
View(df)


###Install packages for mapping
#install.packages("leaflet")
library("leaflet")

d <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 10)
d %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df$Longitude,
    lat = df$Latitude,
    popup = df$`Type of Location`,
    radius = 8,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = "red")