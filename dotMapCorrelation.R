### Look at other variable that may be related burglary
### We are going to bring in Burglary and Vandalism
### This will bring in both Commercial and Residential
### burglary along with Criminal Mischief/Vandalism

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