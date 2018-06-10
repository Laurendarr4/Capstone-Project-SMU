###Capstone Project
##Dallas Open Data-Police Incidents
#6/10/2018

###Scrape data using Socrata API
## Install the required package with:
## install.packages("RSocrata")

library(RSocrata)
library(tidyr)
library(stringr)
library(readr)
library(dplyr)

###Install packages for mapping
#install.packages("leaflet")
#install.packages("leaflet.extras")
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

# Select unique values from objattack to see values available
buildingTypes <- group_by(df1, objattack)
summarise(buildingTypes, sites = n_distinct(incidentnum))

# Create Business or Residential Condition
df1$locClass <- rep(NA, nrow(df1))
df1[df1$objattack == c("Apartment Complex/Building", 
                      "Residential Property Occupied/Vacant"), ][, "locClass"] <- "Residential"
df1[df1$objattack == c("ATM", 
                      "Business Office", 
                      "Commercial Property Occupied/Vacant", 
                      "Entertainment/Sports Venue", 
                      "Financial Institution", 
                      "Goverment Facility", 
                      "Medical Facility", 
                      "Religious Institution", 
                      "Residential Property Occupied/Vacant", 
                      "Resturant/Food Service/Tabc Location", 
                      "Retail Store"), ][, "locClass"] <- "Commercial"
# Check
buildingTypes <- group_by(df1, locClass)
summarise(buildingTypes, sites = n_distinct(incidentnum))

