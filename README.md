

<!-- README.md is generated from README.qmd. Please edit that file -->

<img src="logo/ggpaver-logo.svg" align="right" width="120" alt="ggpaver logo" />

# ggpaver (Still in Development)

<!-- badges: start -->

<!-- badges: end -->

The goal of `ggpaver` is to facilitate the use of pavement plots in R as
a `ggplot2` extension. Pavement plots present univariate continuous data
as tiles ranging between the minimal and maximal values, with each tile
representing an equal share of the data.

## Installation

You can install the development version of `ggpaver` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("git-dwilliams/ggpaver")
```

## Example

``` r
library(ggplot2)
library(ggpaver)

ggplot(diamonds, aes(x = price, y = cut)) +
  geom_pavement(bins = 16) +
  labs(
    title = "A Pavement Plot of Diamond Price (USD) by Cut",
    subtitle = "Each Tile Represents an Equal Share of its Group's Data"
  )
```

<img src="man/figures/README-example-1.png" style="width:100.0%" />
