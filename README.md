<!-- README.md is generated from README.Rmd. Please edit that file -->
nestyr
======

"Nesting" a data frame describes the process of combining values to create a single list-column variable of data frames *within* a data frame. The `tidyr` package makes this process easy with the `nest()` function. See an example here: "<http://r4ds.had.co.nz/many-models.html>".

Nesting in `tidyr` relies on grouping functions from the `dplyr` package to index the rows before nesting. However, as of September of 2018, `dplyr` is still unable to group by list columns (see <https://github.com/tidyverse/tidyr/issues/249>). In other words, you cannot nest variables with a list column not included in your nest. This also means you cannot create multiple nests, as they are list columns.

The `nestyr` package gets around this problem with the `nestyr::nest2()` function. Instead of grouping by list columns directly, it finds an MD5 hash for all objects within any list columns before finding the group indices.

The `nestyr::nest_cols()` function gets around the need to include a row id to nesting columns together while preserving rows. In other words, you can nest horizontally without thinking about row grouping. Like `nest2`, `nest_cols` also works with pre-existing list columns.

Example
-------

Suppose we take the example provided by the "R for Data Science" book by Garret Germund and Hadley Wickham see (<https://github.com/tidyverse/tidyr/issues/249>). In this instance, however, let's say we wanted to nest together the columns `country` and `continent` together, and then nest together the remaining columns by unique country-continent.

``` r
library(gapminder)
library(tidyverse)
library(nestyr)
gapminder %>% 
  nest_cols(country, continent, .key = "country_data") %>% 
  nest2(-country_data)
#> # A tibble: 142 x 2
#>    country_data     data             
#>    <list>           <list>           
#>  1 <tibble [1 x 2]> <tibble [12 x 4]>
#>  2 <tibble [1 x 2]> <tibble [12 x 4]>
#>  3 <tibble [1 x 2]> <tibble [12 x 4]>
#>  4 <tibble [1 x 2]> <tibble [12 x 4]>
#>  5 <tibble [1 x 2]> <tibble [12 x 4]>
#>  6 <tibble [1 x 2]> <tibble [12 x 4]>
#>  7 <tibble [1 x 2]> <tibble [12 x 4]>
#>  8 <tibble [1 x 2]> <tibble [12 x 4]>
#>  9 <tibble [1 x 2]> <tibble [12 x 4]>
#> 10 <tibble [1 x 2]> <tibble [12 x 4]>
#> # ... with 132 more rows
```

Install
-------

``` r
library(devtools)
install_github("JakeNel28/nestyr")
```

Acknowledgements
----------------

The package relies on much of the source code and some documentation used in `tidyr::nest()`, which was developed by Hadley Wickham "<hadley@rstudio.com>", Lionel Henry "<lionel@rstudio.com>", and RStudio <https://www.rstudio.com/>.
