library(dplyr)
library(jsonlite)
### NOTE ####
############
# I have removed my personal google api key which was used to geocode the stations to avoid any unwanted charges due to running this code.

## read in trunstile data for getting ids etc
turns <- read.csv('http://web.mta.info/developers/data/nyct/turnstile/turnstile_200919.txt')

#Base url for google maps api
base <- "https://maps.googleapis.com/maps/api/geocode/json?address="

# Census api key
cen_key <- '97d55623ee041618526d685d56a340986817ea2c'

# Filter down data to more unique stations
turns_filt <- turns %>%
  group_by(STATION,DIVISION) %>%
  summarize(all = sum(ENTRIES))

#add empty lat lon columns to fill
turns_filt$LAT <- NA
turns_filt$LON <- NA

# iterate through stations and query the api
for (i in 1:nrow(turns_filt)){
  tryCatch({ 
    # create an object to store the geo info
    geo <- fromJSON(URLencode(paste(base,paste(turns_filt$STATION[i],"Station",turns_filt$DIVISION[i],'Line New York'),"&key=",key)))

    turns_filt$LON[i] <- geo$results$geometry$location$lng[1] 
    turns_filt$LAT[i]  <-  geo$results$geometry$location$lat[1]
    turns_filt$geo_type[i] <- geo$results$types[[1]]
    message(i)
  }, error=function(e){}) 
}

# create empty columns for census geography ids, these are known as fips and are how you identify the location for
# pulling in data
turns_filt$State_FIPS <- NA
turns_filt$County_FIPS <- NA
turns_filt$Tract_FIPS <- NA

# run through each row and query the census api to get fips codes based on latitude and longitute coordinates
for (k in which(is.na(turns_filt$State_FIPS))){
  geo <- fromJSON(paste0('https://geocoding.geo.census.gov/geocoder/geographies/coordinates?x=',turns_filt$LON[k],'&y=',turns_filt$LAT[k],'&benchmark=4&vintage=4'))
  turns_filt$State_FIPS[k] <- geo$result$geographies$`Census Tracts`$STATE
  turns_filt$County_FIPS[k] <- geo$result$geographies$`Census Tracts`$COUNTY
  turns_filt$Tract_FIPS[k] <- geo$result$geographies$`Census Tracts`$TRACT
  message(k)
}


# Then we pull in the data for all tracts in all counties in new york as one query. 

cen_dat <- fromJSON(paste0('https://api.census.gov/data/2018/acs/acs5/subject?get=NAME,S0101_C05_001E,S0101_C01_001E,S2001_C02_011E,S2001_C02_012E,S2001_C01_002E,S2403_C01_001E,S2403_C01_012E,S2403_C01_017E&for=tract:*&in=state:36&in=county:*&key=',cen_key))

# Save the first row as the new column names then delete the row itself.
colnames(cen_dat) <- cen_dat[1,]
cen_dat <- cen_dat[-1,]

# Replace the api code names with a more readable label.
colnames(cen_dat)[2:9] <-c('Female_Population',
                           'Total_Population',
                           'P_75_100k',
                           'P_over_100k',
                           'median_income',
                           'tot_emp',
                           'emp_info',
                           'emp_prof')

# Convert the data to a dataframe and ensure that the columns are numeric so we can perform math functions on them.
cen_dat <- as.data.frame(cen_dat)
cen_dat[,2:9] <- sapply(cen_dat[,2:9],as.numeric)

# Calculate % female ppopulation based on estimate nummbers given by the census api.
cen_dat$p_f_pop <- cen_dat$Female_Population/cen_dat$Total_Population

# Calculate employment percentage in the industries we are focused on using the total population surveyed.
cen_dat$p_emp_info <- cen_dat$emp_info/cen_dat$tot_emp
cen_dat$p_emp_prof <- cen_dat$emp_prof/cen_dat$tot_emp


# We can now fill the columns based on rows that match by FIPS code. We will also multiply percentages by 100 to make them easily 
# readable.
turns_filt$p_f_pop <- cen_dat$p_f_pop[match(paste0(turns_filt$State_FIPS,turns_filt$County_FIPS,turns_filt$Tract_FIPS),paste0(cen_dat$state,cen_dat$county,cen_dat$tract))]
turns_filt$p_emp_info <- cen_dat$p_emp_info[match(paste0(turns_filt$State_FIPS,turns_filt$County_FIPS,turns_filt$Tract_FIPS),paste0(cen_dat$state,cen_dat$county,cen_dat$tract))]
turns_filt$p_emp_prof <- cen_dat$p_emp_prof[match(paste0(turns_filt$State_FIPS,turns_filt$County_FIPS,turns_filt$Tract_FIPS),paste0(cen_dat$state,cen_dat$county,cen_dat$tract))]
turns_filt$p_75_100k <- cen_dat$P_75_100k[match(paste0(turns_filt$State_FIPS,turns_filt$County_FIPS,turns_filt$Tract_FIPS),paste0(cen_dat$state,cen_dat$county,cen_dat$tract))]/100
turns_filt$p_over_100k <- cen_dat$P_over_100k[match(paste0(turns_filt$State_FIPS,turns_filt$County_FIPS,turns_filt$Tract_FIPS),paste0(cen_dat$state,cen_dat$county,cen_dat$tract))]/100

# Export the stations data combined with tract level census data so we can read into the main python notebook.
write.csv(turns_filt, 'geocoded_cen_dat.csv', row.names = F)
