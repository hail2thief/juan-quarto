# libraries
library(tidyverse)
library(leaflet)
library(tidygeocoder)

# make travel data
travels = tribble(~year, ~city, ~country,
        2012, c("Mexico City", "Puebla"), "Mexico",
        2018, c("Tel Aviv", "Haifa", "Jerusalem", 
                "Bethlehem", "Nazareth"), "Israel",
        2017, c("Berlin", "Munich"), "Germany",
        2017, c("Prague"), "Czech Republic",
        2016, c("Lima", "Arequipa", "Cusco"), "Peru",
        2016, c("Bogota", "Medellin", "Cartagena"), "Colombia",
        2016, c("Montreal"), "Canada",
        2015, c("Dublin", "Cork", "Galway"), "Ireland",
        2015, c("Belfast", "Derry"), "Northern Ireland",
        2015, c("Edinburgh"), "Scotland",
        2017, c("Medellin", "Cartagena", "Cali", "Bogota", "Corinto"), "Colombia",
        2014, c("Rio de Janeiro"), "Brazil", 
        2017, c("Shanghai", "Beijing", "Huangshan", "Hangzhou", "Zhuzhou"), "China",
        2015, c("Mumbai", "Dehli", "Udaipur"), "India",
        2024, c("Buenos Aires", "Mendoza"), "Argentina", 
        2024, c("Santiago", "Valparaiso"), "Chile",
        2025, c("Medellin", "Cali"), "Colombia",
        2023, c("Tokyo", "Kyoto", "Hiroshima", "Osaka"), "Japan",
        2021, c("Medellin", "Bello"), "Colombia",
        2019, c("Guatemala City", "Antigua"), "Guatemala",
        2019, c("Copenhagen", "Aarhus"), "Denmark",
        2019, c("Bergen", "Oslo"), "Norway",
        2019, c("Toronto"), "Canada") |> 
  unnest(city)


# geocode
travels_geo = travels |>
  mutate(location = paste0(city, ", ", country)) |>
  geocode(location, method = "osm", lat = latitude, long = longitude)


# plot
leaflet(travels_geo) |>
  addTiles() |>
  addCircleMarkers(
    lng = ~longitude, lat = ~latitude,
    popup = ~paste0("<strong>", city, ", ", country, "</strong><br>Year: ", year),
    radius = 5, fillOpacity = 0.8,
    color = ~colorFactor("Set1", year)(year)
  )
