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
remotes::install_github("BigelowLab/neracoos")
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

Let's be sure to close the `ncdf4` connection now that we have our data in hand.

```
nc_close(X)
```

### Regularizing an irregular time series

Note that `tsibble` supports both regular and irregular time series.  You can see that this one is irregular as the time spacing shows variability.  But note also the `[!]` in the printout header. If this were a regular time series, then the interval would be shown.  We can regularize this time series by judicious rounding, but first we should know more about the frequency.

Let's find the differences between consecutive observations in minutes.

```
dt <- diff_time(x$time, units = "mins")
summary(as.numeric(dt))
#     Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
#    30.00     30.00     30.00     37.17     30.00 283350.00 
```

Well, that's is surprising... the median is 30 minutes, but the head of the table would lead us to believe that they are hourly.  And the large max tells us there is a break in the series somewhere that is about 197 days long.

```
ints_30 <- seq(from = 15, to = 120 + 30, by = 30)
ix <- as.vector(table(findInterval(as.numeric(dt),ints_30)))
names(ix) <- c("15-44", "45-74", "75-104", "105-134", "135-Inf")
ix
#  15-44   45-74  75-104 105-134 135-Inf 
# 223578   50758       2      16      44 
```

So, most, but not all, are within a +/-15 minute band around 30 minutes (between 15 and 44 minutes).  It's a mixed bag. Let's see what the actual whole minute distribution looks like.

```
m <- format(x$time, "%M")
table(m)
#     00     29     30     59 
# 110773  37269  74535  51822 
```

Ah, so there are pretty much on the hour and half hour.  We can reasonably assign them to the nearest 30 minute interval.

```
x <- regularize(x, unit = "30 min")# # A tsibble: 274,399 x 5 [30m] <UTC>
#    time                conductivity temperature salinity sigma_t
#    <dttm>                     <dbl>       <dbl>    <dbl>   <dbl>
#  1 2001-07-10 04:00:00         40.2        17.0     30.9    22.4
#  2 2001-07-10 05:00:00         40.2        17.0     31.0    22.4
#  3 2001-07-10 06:00:00         40.1        16.9     31.0    22.4
#  4 2001-07-10 07:00:00         40.0        16.8     30.9    22.5
#  5 2001-07-10 08:00:00         39.8        16.6     30.9    22.5
#  6 2001-07-10 09:00:00         39.4        16.2     30.9    22.5
#  7 2001-07-10 10:00:00         39.3        16.1     30.9    22.5
#  8 2001-07-10 11:00:00         38.9        15.6     30.9    22.6
#  9 2001-07-10 12:00:00         38.7        15.5     30.9    22.7
# 10 2001-07-10 13:00:00         39.0        15.7     30.8    22.6
# # … with 274,389 more rows
```

Regularizing allows for gap analysis and (simple) filling.

``` 
has_gaps(x)
# # A tibble: 1 x 1
#   .gaps
#   <lgl>
# 1 TRUE 

scan_gaps(x)
# # A tsibble: 65,555 x 1 [30m] <UTC>
#    time               
#    <dttm>             
#  1 2001-07-10 04:30:00
#  2 2001-07-10 05:30:00
#  3 2001-07-10 06:30:00
#  4 2001-07-10 07:30:00
#  5 2001-07-10 08:30:00
#  6 2001-07-10 09:30:00
#  7 2001-07-10 10:30:00
#  8 2001-07-10 11:30:00
#  9 2001-07-10 12:30:00
# 10 2001-07-10 13:30:00
# # … with 65,545 more rows

y <- fill_gaps(x, 
  conductivity = median(conductivity, na.rm = TRUE),
  salinity = -99)
# # A tsibble: 339,954 x 5 [30m] <UTC>
#    time                conductivity temperature salinity sigma_t
#    <dttm>                     <dbl>       <dbl>    <dbl>   <dbl>
#  1 2001-07-10 04:00:00         40.2        17.0     30.9    22.4
#  2 2001-07-10 04:30:00         34.7        NA      -99      NA  
#  3 2001-07-10 05:00:00         40.2        17.0     31.0    22.4
#  4 2001-07-10 05:30:00         34.7        NA      -99      NA  
#  5 2001-07-10 06:00:00         40.1        16.9     31.0    22.4
#  6 2001-07-10 06:30:00         34.7        NA      -99      NA  
#  7 2001-07-10 07:00:00         40.0        16.8     30.9    22.5
#  8 2001-07-10 07:30:00         34.7        NA      -99      NA  
#  9 2001-07-10 08:00:00         39.8        16.6     30.9    22.5
# 10 2001-07-10 08:30:00         34.7        NA      -99      NA  
# # … with 339,944 more rows
```

You can see that the time series has been populated with missing records at 30 minute intervals,
and that the variables have been assigned either `NA` or a value where specified.  For instance,
where gaps have been filled for salinity we assigned -99 while for conductivity we replace with the median conductivity of the gappy input.

