### Look at other variable that may be related burglary
### We are going to bring in Burglary and Vandalism
### This will bring in both Commercial and Residential
### burglary along with Criminal Mischief/Vandalism

## Install the required package

library(RSocrata)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)
library(leaflet)
library(leaflet.extras)

url2 = "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$where=ucroffense like '%BURGLARY%' OR ucroffense like '%VANDALISM%'"

df2 <- read.socrata(url2, app_token = NULL, email= NULL, password = NULL)

#Check for correct data loaded
head(df2)
# Take the Point and () out of the location1 data
# Seperate Point and ()
df2$latlon <- gsub(".*\\((.*)\\).*","\\1", df2$location1)
# Spilt out into list 2 columns
LatLon <- str_split_fixed((df2$latlon)," ",2)
# Name columns in list
colnames(LatLon) <- c("Longitude", "Latitude")
# Covert into dataframe
df_LatLon <-as.data.frame(LatLon)

# Bring into current frame
# Convert to Numeric from factor
df2$Latitude <- as.numeric(as.character(df_LatLon$Latitude))
df2$Longitude <- as.numeric(as.character(df_LatLon$Longitude))

#remove LatLon list and data frame df_LatLon
rm(LatLon)
rm(df_LatLon)

# Check UCR Offense
table(df2$ucroffense)

# Remove obs w/o location
# df2 <- df2[!(is.na(df2$location1) | df2$location1==""),]

# Build year frames
df2_2015 <- df2[ which(df2$year1=='2015'),]
df2_2016 <- df2[ which(df2$year1=='2016'),]
df2_2017 <- df2[ which(df2$year1=='2017'),]

# Create a palette
pal <- colorFactor(c("#A0A0FF", "#FFA0A0", "#4EED34"), 
          domain = c("BURGLARY-BUSINESS",
                    "BURGLARY-RESIDENCE",
                    "VANDALISM & CRIM MISCHIEF"))

# 2015 Map
bCM_2015 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
bCM_2015 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df2_2015$Longitude,
    lat = df2_2015$Latitude,
    popup = paste("MO: ", df2_2015$mo, "<br>",
      "Premise: ", df2_2015$premise, "<br>",
      "Date: ", df2_2015$date1, "<br>",
      "Day: ", df2_2015$day1,
      "Time: ", df2_2015$time1,
      "Zip: ", df2_2015$zipcode),
    radius = 5,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = pal(df2_2015$ucroffense))%>%
  addLegend("bottomright", pal = pal, values = df2_2015$ucroffense,
    title = "2015 Dallas Burg ~ V&CM")

# 2016 Map
bCM_2016 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
bCM_2016 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df2_2016$Longitude,
    lat = df2_2016$Latitude,
    popup = paste("MO: ", df2_2016$mo, "<br>",
      "Premise: ", df2_2016$premise, "<br>",
      "Date: ", df2_2016$date1, "<br>",
      "Day: ", df2_2016$day1,
      "Time: ", df2_2016$time1,
      "Zip: ", df2_2016$zipcode),
    radius = 5,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = pal(df2_2016$ucroffense))%>%
  addLegend("bottomright", pal = pal, values = df2_2016$ucroffense,
    title = "2016 Dallas Burg ~ V&CM")

# 2017 Map
bCM_2017 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
bCM_2017 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df2_2017$Longitude,
    lat = df2_2017$Latitude,
    popup = paste("MO: ", df2_2017$mo, "<br>",
      "Premise: ", df2_2017$premise, "<br>",
      "Date: ", df2_2017$date1, "<br>",
      "Day: ", df2_2017$day1,
      "Time: ", df2_2017$time1,
      "Zip: ", df2_2017$zipcode),
    radius = 5,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = pal(df2_2017$ucroffense))%>%
  addLegend("bottomright", pal = pal, values = df2_2017$ucroffense,
    title = "2017 Dallas Burg ~ V&CM") %>%
  addLayersControl(
    baseGroups = df2_2017$month1,
    options = layersControlOptions(collapse = FALSE)
  )

# Try mini chart don't think is going to work for this application
# could have other functions
bCM_17 <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
bCM_17 %>% addProviderTiles(providers$Stamen.Toner) %>%
  addMinicharts(
    df2_2017$Longitude, df2_2017$Latitude,
    add
  )
