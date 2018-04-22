
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
df$latlon <- gsub(".*\\((.*)\\).*", "\\1", df$location1)
# Check to see if Point and () are removed
head(df$latlon)

#Seperates into list
latLongList <- str_split_fixed(df$latlon, " ", 2)
head(latLongList)







###Install packages for mapping
install.packages("leaflet")
library("leaflet")