devtools::load_all("~/Dropbox/code/R/neracoos")
library(tsibble)
library(lubridate)
library(dplyr)

if (!exists("raw_a01")){
  X <- get_Maine_buoy(buoy = "A01", dataset = "CTD 1m", form = 'ncdf')
  raw_a01 <- nc_get_table(X,
                         dnames = "time",
                         vnames = c("conductivity",
                                    "temperature",
                                    "salinity",
                                    "sigma_t"),
                         form = "table")
  ts_a01 <- nc_get_table(X,
                    dnames = "time",
                    vnames = c("conductivity",
                               "temperature",
                               "salinity",
                               "sigma_t"),
                    form = "tsibble")
  nc_close(X)
}

# force to regular
if (!exists("rx", mode = "list")){
  rx <- regularize(ts_a01, unit = '30 min')
  rx
}

if (!exists("x", mode = "list")){
  x <- raw_a01
}
