set.seed(20261020)

# Ensure that distributions have the same range for comparisons:
rescale <- function(x, low = 0, high = 1000) {
  shifted_min <- (x - min(x))
  original_range <- max(x) - min(x)
  new_range <- high - low
  rescaled <- shifted_min / original_range * new_range + low
  return(rescaled)
}

n <- 10000

normal <- data.frame(
  x = rescale(rnorm(n, mean = 0, sd = 1)),
  distribution = "Normal"
)

left_skewed <- data.frame(
  x = rescale(rbeta(n, shape1 = 8, shape2 = 2)),
  distribution = "Left-skewed"
)

right_skewed <- data.frame(
  x = rescale(rbeta(n, shape1 = 2, shape2 = 8)),
  distribution = "Right-skewed"
)

bimodal <- data.frame(
  x = rescale(
    c(
      rnorm(n / 2, mean = -2, sd = 0.7),
      rnorm(n / 2, mean = 2, sd = 0.7)
    )
  ),
  distribution = "Bimodal"
)

uniform <- data.frame(
  x = rescale(runif(n)),
  distribution = "Uniform"
)

distributions <- rbind(
  normal,
  left_skewed,
  right_skewed,
  bimodal,
  uniform
)

# For ordering in visualizations:
distributions$distribution <- factor(
  distributions$distribution,
  levels = c(
    "Normal",
    "Left-skewed",
    "Right-skewed",
    "Bimodal",
    "Uniform"
  )
)

usethis::use_data(distributions, overwrite = TRUE)
