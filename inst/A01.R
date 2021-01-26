devtools::load_all("/mnt/ecocast/corecode/R/neracoos")
library(tsibble)
library(lubridate)
library(dplyr)

if (FALSE){
  X <- get_Maine_buoy(buoy = "A01", dataset = "CTD 1m", form = 'ncdf')
  raw <- nc_get_table(X,
                    dnames = "time",
                    vnames = c("conductivity",
                               "temperature",
                               "salinity",
                               "sigma_t"),
                    form = "tsibble")
  nc_close(X)
}

x <- regularize(raw, unit = '30 min')

