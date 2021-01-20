# [neracoos](http://www.neracoos.org/thredds/catalog.html)

[R-language](https://www.r-project.org/) tools for working with [THREDDS](https://www.unidata.ucar.edu/software/tds/current/) served data from [NERACOOS](http://www.neracoos.org/thredds/catalog.html).

## Requirements

  + [R v4+](https://www.r-project.org/)
  
  + [dplyr](https://CRAN.R-project.org/package=dplyr)
  
  + [rlang](https://CRAN.R-project.org/package=rlang)
  
  + [ncdf4](https://CRAN.R-project.org/package=ncdf4)
  
  + [thredds](https://github.com/BigelowLab/thredds)
    

## Installation

```
remotes::install_github(https://github.com/BigelowLab/neracoos)
```

### Getting Buoy data

```
library(neracoos)
X <- get_Maine_buoy(buoy = "A01", )
