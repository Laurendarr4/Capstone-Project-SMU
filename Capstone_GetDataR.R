###Capstone Project
##Dallas Open Data-Police Incidents
#3/31/2018

###Scrape data using Socrata API
## Install the required package with:
## install.packages("RSocrata")

library("RSocrata")

#Use soDA URL to access Incident Data; set limit on number of rows per page to 500 for now
url= "https://www.dallasopendata.com/resource/qqc2-eivj.csv?$limit=500&$offset=0"

df <- read.socrata(url, app_token = NULL, email= NULL, password= NULL)

#Check for correct data loaded
head(df)

#select rows of importance



###Install packages for mapping
install.packages("leaflet")
library("leaflet")
