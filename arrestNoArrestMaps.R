###Capstone Project
##Dallas Open Data-Police Incidents
## Dot Maps
#6/10/2018

###Scrape data using Socrata API
## Install the required packages if you don't have them

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


## CLEAN LAT & LON
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

# Check UCR Offense
buildingTypes <- group_by(df1, ucroffense)
summarise(buildingTypes, sites = n_distinct(incidentnum))

## CREATE Arrest or Suspended variable
## in df 38,808 are Suspended, 644 Open, 1,411 Clear by Arrest, 
## 471 Clear by Exceptional Arrest and two marked with SW

# First let's look at open investigations into Burglaries

df_Open <- df1[ which(df1$status=='Open'
            & df1$ucroffense==c("BURGLARY-BUSINESS","BURGLARY-RESIDENCE")),]
# Map Open Investigations
# Create a palette
pal <- colorFactor(c("#A0A0FF", "#FFA0A0"), domain = c("BURGLARY-BUSINESS","BURGLARY-RESIDENCE"))

d_Open <- leaflet() %>% setView(lng = -96.7970, lat = 32.7767, zoom = 11)
d_Open %>% addProviderTiles(providers$Stamen.Toner) %>%
  addCircleMarkers(lng = df_Open$Longitude,
    lat = df_Open$Latitude,
    popup = paste("MO: ", df_Open$mo, "<br>",
      "Premise: ", df_Open$premise, "<br>",
      "Date: ", df_Open$date1, "<br>",
      "Day: ", df_Open$day1,
      "Time: ", df_Open$time1,
      "Zip: ", df_Open$zipcode),
    radius = 5,
    stroke = FALSE,
    fillOpacity = 0.75,
    color = pal(df_Open$ucroffense))%>%
  addLegend("bottomright", pal = pal, values = df_Open$ucroffense,
    title = "Open Burglary Investigations")

# Many years of still open cases. Cases are suspended if the theft is small
# less than 500 dollars.
# There is no value field of estimation of what is stolen

## CREATE VARIABLE to analyze arrest
df1$Arrest <- ifelse(df1$status == c("Clear by Arrest", 
                                    "Clear by Exceptional Arrest"),1,0)
# Percent that lead to arrest
# Table zip code with No Arrest=0 and Arrest=1
tbl <- table(df1$zipcode, df1$Arrest)
arrestZip <- as.data.frame.matrix(tbl)
arrestZip$NoArrest <- arrestZip$`0`
arrestZip$Arrest <- arrestZip$`1`
# Remove 0, 1 columns
arrestZip <- arrestZip[, 3:4]
# Create % that end in arrest
arrestZip$PercentArrested <- arrestZip$Arrest/arrestZip$NoArrest

# Check statistics 
summary(arrestZip)
# mean is 2.0%, while median is 1.84%
# StDev is 1.86%
sd(arrestZip$PercentArrested)
# Coefficient of variation, as percent
# Almost 91% there is a lot of variation
sd(arrestZip$PercentArrested)/ 
  mean(arrestZip$PercentArrested)*100