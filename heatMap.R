### Heat Map Script

# Install if not already

library(RSocrata)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)
library(leaflet)
library(leaflet.extras)

#Use soDA URL to access Incident Data; set limit on number of rows per page to 500 for now
url = "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$where=offincident like '%BURGLARY%'"

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

# Heatmap example
# Detail of map function by API Author
# https://github.com/bhaskarvk/leaflet.extras/blob/master/R/webGLHeatmap.R
# STILL IN PROGRESS
h <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
h %>% addProviderTiles(providers$OpenStreetMap.BlackAndWhite) %>%
  addWebGLHeatmap(lng = df_2016$Longitude,
    lat = df_2016$Latitude,
    size = 1000, 
    opacity = 0.60)

h2 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 12)
h2 %>% addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
  addWebGLHeatmap(lng = df_2016$Longitude,
    lat = df_2016$Latitude,
    size = 50, units = "px",
    intensity = .15,
    gradientTexture = "skyline",
    opacity = 0.60)

# Attempt Layer Control
h3 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 12)
h3 %>% addTiles(group = "OSM (default)" ) %>% 
  # Base Groups #
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "Mapnik") %>%
  addProviderTiles(providers$OpenStreetMap.BlackAndWhite, group = "Mapnik-B/W") %>%
  addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner-Lite") %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group = "DarkMatter") %>%
  addWebGLHeatmap(lng = df_2016$Longitude,
    lat = df_2016$Latitude,
    size = 50, units = "px",
    intensity = .15,
    gradientTexture = "skyline",
    opacity = 0.60) %>%
  addLayersControl(
    baseGroups = c("OSM (default)", 
                  "Mapnik", 
                  "Mapnik-B/W", 
                  "Toner", 
                  "Toner-Lite", 
                  "DarkMatter"),
    options = layersControlOptions(collapsed = FALSE)
  )