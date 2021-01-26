# [neracoos](http://www.neracoos.org/thredds/catalog.html)

[R-language](https://www.r-project.org/) tools for working with [THREDDS](https://www.unidata.ucar.edu/software/tds/current/) served data from [NERACOOS](http://www.neracoos.org/thredds/catalog.html).

## Requirements

  + [R v4+](https://www.r-project.org/)
  
  + [dplyr](https://CRAN.R-project.org/package=dplyr)
  
  + [rlang](https://CRAN.R-project.org/package=rlang)
  
  + [ncdf4](https://CRAN.R-project.org/package=ncdf4)
  
  + [thredds](https://github.com/BigelowLab/thredds)
  
  + [tsibble](https://CRAN.R-project.org/package=tsibble)
    

## Installation

```
remotes::install_github(https://github.com/BigelowLab/neracoos)
```

### Getting Buoy data

```
library(neracoos)
X <- get_Maine_buoy(buoy = "A01", dataset = "CTD 1m", form = 'ncdf')
x <- nc_get_table(X, 
                  dnames = "time",
                  vnames = c("conductivity",
                             "temperature",
                             "salinity",
                             "sigma_t"))
# # A tibble: 274,400 x 5
#    time                conductivity temperature salinity sigma_t
#    <dttm>                     <dbl>       <dbl>    <dbl>   <dbl>
#  1 2001-07-10 04:00:00         40.2        17.0     30.9    22.4
#  2 2001-07-10 05:00:01         40.2        17.0     31.0    22.4
#  3 2001-07-10 06:00:00         40.1        16.9     31.0    22.4
#  4 2001-07-10 07:00:00         40.0        16.8     30.9    22.5
#  5 2001-07-10 08:00:01         39.8        16.6     30.9    22.5
#  6 2001-07-10 09:00:00         39.4        16.2     30.9    22.5
#  7 2001-07-10 10:00:00         39.3        16.1     30.9    22.5
#  8 2001-07-10 11:00:01         38.9        15.6     30.9    22.6
#  9 2001-07-10 12:00:00         38.7        15.5     30.9    22.7
# 10 2001-07-10 13:00:00         39.0        15.7     30.8    22.6
# # … with 274,390 more rows
```

You can also retrieve as a [tsibble](https://CRAN.R-project.org/package=tsibble). Observe that we retrieve one fewer record that for tibble output.  That's because transformation to a time-series disallows duplicates - so we one record duplicated by time. `tsibble` does allow for duplicated time as long as a key variable is assigned also - a key is a like a grouping. In our simplistic usage we don't assign a key, so duplicates are disallowed.

```
x <- nc_get_table(X, 
                  dnames = "time",
                  vnames = c("conductivity",
                             "temperature",
                             "salinity",
                             "sigma_t"),
                  form = "tsibble")
# # A tsibble: 274,399 x 5 [!] <UTC>
#    time                conductivity temperature salinity sigma_t
#    <dttm>                     <dbl>       <dbl>    <dbl>   <dbl>
#  1 2001-07-10 04:00:00         40.2        17.0     30.9    22.4
#  2 2001-07-10 05:00:01         40.2        17.0     31.0    22.4
#  3 2001-07-10 06:00:00         40.1        16.9     31.0    22.4
#  4 2001-07-10 07:00:00         40.0        16.8     30.9    22.5
#  5 2001-07-10 08:00:01         39.8        16.6     30.9    22.5
#  6 2001-07-10 09:00:00         39.4        16.2     30.9    22.5
#  7 2001-07-10 10:00:00         39.3        16.1     30.9    22.5
#  8 2001-07-10 11:00:01         38.9        15.6     30.9    22.6
#  9 2001-07-10 12:00:00         38.7        15.5     30.9    22.7
# 10 2001-07-10 13:00:00         39.0        15.7     30.8    22.6
# # … with 274,389 more rows                             
```

When you are done, be sure to close the `ncdf4` connection.

```
nc_close(X)
```
