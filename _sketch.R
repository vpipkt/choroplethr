
county_choropleth_acs("B19301")

# continuous scale, zooing in on all counties in New York, New Jersey and Connecticut
county_choropleth_acs("B19301", num_colors=1, state_zoom=c("new york", "new jersey", "connecticut"))

# zooming in on the 5 counties (boroughs) that make up New York City
library(choroplethrMaps)
data(county.regions)

nyc_county_names <- c("kings", "bronx", "new york", "queens", "richmond")
nyc_county_fips <- subset(county.regions, 
 state.name == 'new york' & county.name %in% nyc_county_names)$region
county_choropleth_acs("B19301", num_colors=1, county_zoom=nyc_county_fips)




# States with greater than 1M residents
library(choroplethr)
df       <- get_acs_data("B01003", "state")[[1]] # population
#df$value <- ifelse(df$value < 1000000, '< 1M', '> 1M')
df$value <- cut(df$value, breaks = c(0, 1e6, Inf), labels = c('< 1M', '> 1M'))
state_choropleth(df, title="States with a population over 1M", legend="Population")



# Counties with greater than or greater than 1M residents
df       <- get_acs_data("B01003", "county")[[1]] # population
df$value <- ifelse(df$value < 1000000, '< 1M', '> 1M')
county_choropleth(df, title="Counties with a population over 1M", legend="Population")
}

data(df_pop_state)
df_pop_state$value <- cut(df_pop_state$value, breaks = c(0, 1e6, Inf), labels = c('< 1M', '> 1M'))
state_choropleth(df_pop_state, title="Which states have less than 1M people?")

data(df_pop_state)
df_pop_state$value <- factor(df_pop_state$value > 1e6, labels = c('< 1M', '> 1M'))
state_choropleth(df_pop_state, title="Which states have less than 1M people?")

data(df_pop_state)
df_pop_state$value2 <- '> 1M'
df_pop_state$value2[df_pop_state$value < 1e6] <- '< 1M'
df_pop_state$value <- df_pop_state$value2
state_choropleth(df_pop_state, title="Which states have less than 1M people?")
