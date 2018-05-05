
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

###Install packages for mapping
#install.packages("leaflet")
library("leaflet")


#Use soDA URL to access Incident Data; set limit on number of rows per page to 500 for now
url= "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$limit=500&$offset=0"

df <- read.socrata(url, app_token = NULL, email= NULL, password= NULL)

#Check for correct data loaded
head(df)

# remove all records that do not have any information from the column Location1
df1 <- df[!(is.na(df$location1) | df$location1==""),]

# View Data 
#View(df1)


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

### Create leaflet map object to test using address as popup 
map_test <- leaflet() %>% 
  addTiles() %>% 
  addMarkers(data = df1, lng= ~Longitude, lat= ~Latitude, popup = ~address)
map_test


# Leaflet map
d <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 10)
d %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df1$Longitude,
    lat = df1$Latitude,
    popup = df1$`Type of Location`,
    radius = 8,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = "red")
