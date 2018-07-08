###Capstone Project
##Dallas Open Data-Police Incidents
#3/31/2018

###Scrape data using Socrata API
## Install the required package with:
# install.packages("RSocrata")
# install.packages("readr")

library(RSocrata)
library(tidyr)
library(stringr)
library(readr)

###Install packages for mapping
# install.packages("leaflet")
# install.packages("leaflet.extras")
library(leaflet)
library(leaflet.extras)


# Use soDA URL to access Incident Data; set limit on number of rows per page to 500 for now
url = "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$where=offincident like '%BURGLARY%'"

df <- read.socrata(url, app_token = NULL, email= NULL, password= NULL)

#Check for correct data loaded
head(df)

# remove all records that do not have any information from the column Location1
df1 <- df[!(is.na(df$location1) | df$location1==""),]

# View Data 
View(df1)


# Take the Point and () out of the location1 data
# Seperate Point and ()
df1$latlon <- gsub(".*\\((.*)\\).*","\\1", df1$location1)
# Spilt out into list 2 columns
LatLon <- str_split_fixed((df1$latlon)," ",2)
# Name columns in list
colnames(LatLon) <- c("Longitude", "Latitude")
# Covert into dataframe
df_LatLon <-as.data.frame(LatLon)

# Bring into current frame
# Convert to Numeric from factor
df1$Latitude <- as.numeric(as.character(df_LatLon$Latitude))
df1$Longitude <- as.numeric(as.character(df_LatLon$Longitude))

#remove LatLon list and data frame df_LatLon
rm(LatLon)
rm(df_LatLon)

### Create leaflet map object to test using address as popup (This took awhile with all records!)
# map_test <- leaflet() %>% 
#  addTiles() %>% 
#  addMarkers(data = df1, lng= ~Longitude, lat= ~Latitude, popup = ~address)
# map_test

# Break data into 2016 and 2017
# We are using date 1, which is the date of the occurrence of
# the incident
df_2016 <- df1[ which(df1$year1=='2016'),]
df_2017 <- df1[ which(df1$year1=='2017'),]


### Leaflet Cluster Maps
# Notes: Cluster maps are an extension of dot/marker maps. When markers are too dense they become difficult to interpret.
# Cluster maps cluster markers together and label the number of markers contained within each marker.
# As the view zooms in the clusters will split into smaller, more geographically specific clusters.
# This method is also computationally more efficient if there are a large number of individual markers. 
# Default cluster radius is 80 pixels, can be changed.

# Cluster Map Example: Mike's first cluster map
# Burglary in Dallas
# TIME: 2016
c_2016 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
c_2016 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addMarkers(lng = df_2016$Longitude,
    lat = df_2016$Latitude,
    popup = paste("MO: ", df_2016$mo, "<br>",
      "Premise: ", df_2017$premise, "<br>",
      "Date: ", df_2016$date1, "<br>",
      "Day: ", df_2016$day1,
      "Time: ", df_2016$time1,
      "Zip: ", df_2016$zipcode),
    clusterOptions = markerClusterOptions(),
    labelOptions = labelOptions(noHide = T,
      direction = 'auto'))

# Cluster Map
# Burglary in Dallas
# TIME: 2017
c_2017 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
c_2017 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addMarkers(lng = df_2017$Longitude,
    lat = df_2017$Latitude,
    popup = paste("MO: ", df_2017$mo, "<br>",
      "Premise: ", df_2017$premise, "<br>",
      "Date: ", df_2017$date1, "<br>",
      "Day: ", df_2017$day1,
      "Time: ", df_2017$time1,
      "Zip: ", df_2017$zipcode),
    clusterOptions = markerClusterOptions(),
    labelOptions = labelOptions(noHide = T,
      direction = 'auto'))