# Changes to choroplethrMaps package: ? JTB or to choroplethr itself?
#  -Create object df_state_area in choroplethrMaps
#  -Create function normalize_state_data in chorplethr
#  -Create object df_county_area data 
#  -Create function normalize_county_data


library(dplyr)
library(choroplethrMaps)
data(county.regions)
head(county.regions)

#maybe county.regions or state.regions is a better place for the area data?


## check out the area measurements from choroplethrMaps
data(county.map)
head(county.map)
nrow(county.regions)

county.map %>% group_by(region) %>% summarise(Area = first(CENSUSAREA)) -> df_county_area
nrow(df_county_area) == nrow(county.regions)
#check set of counties is the same
nrow(merge(df_county_area, county.regions, all.y = T)) == nrow(county.regions)
#look for any weird stuff, zero or negative areas?
summary(df_county_area) #what unit of measure is Area?

# compare to attribute tables in US Census Bureau cartographic boundary small scale 
zipfile <- 'cb_2014_us_county_20m.zip'
download.file('http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_county_20m.zip', destfile = zipfile)
unzip(zipfile)
#https://github.com/hadley/ggplot2/wiki/plotting-polygon-shapefiles

require("rgdal") # requires sp, will use proj.4 if installed
require("maptools")
require("ggplot2")
require("plyr")

countyShp <- readOGR(dsn = '.', layer = 'cb_2014_us_county_20m')
head(countyShp@data)
nrow(countyShp@data)

uscbCo <- countyShp@data
uscbCo$TOTALAREA <- uscbCo$ALAND + uscbCo$AWATER
uscbCo$region <- paste0(uscbCo$STATEFP, uscbCo$COUNTYFP) #note this misses leading zeros

uscbCo <- merge(uscbCo, df_county_area, by = 'region', all.x = T)
summary(uscbCo)

plot(uscbCo[,9:12])

summary(lm(Area ~ ALAND, uscbCo))
# so county.map is only the land area only, but not sure in what unit of measure.
#http://quickfacts.census.gov/qfd/states/10/10001.html
uscbCo[317,"ALAND"]  #shapefile metadata (.xml) says this is in square meters.
uscbCo[317,"Area"]  #seems to be square miles. 

