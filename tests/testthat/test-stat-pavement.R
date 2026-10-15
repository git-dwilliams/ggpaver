# Adapted from test-stat-boxplot.R
test_that("stat_pavement drops missing rows with a warning", {
  p1 <- ggplot2::ggplot(PlantGrowth, ggplot2::aes(x = group, y = weight)) +
    geom_pavement(position = "dodge") +
    ggplot2::scale_x_discrete(limits = c("trt1", "ctrl"))

  p2 <- ggplot2::ggplot(PlantGrowth, ggplot2::aes(x = group, y = weight)) +
    geom_pavement(position = "dodge2") +
    ggplot2::scale_x_discrete(limits = c("trt1", "ctrl"))

  expect_snapshot_warning(ggplot2::ggplot_build(p1))
  expect_snapshot_warning(ggplot2::ggplot_build(p2))
})

test_that("stat_pavement can suppress warning about missing rows", {
  p1 <- ggplot2::ggplot(PlantGrowth, ggplot2::aes(x = group, y = weight)) +
    geom_pavement(position = "dodge", na.rm = TRUE) +
    ggplot2::scale_x_discrete(limits = c("trt1", "ctrl"))

  expect_silent(ggplot2::ggplot_build(p1))
})

test_that("stat_pavement errors with missing x/y aesthetics", {
  p <- ggplot2::ggplot(PlantGrowth) +
    geom_pavement()
  expect_snapshot_error(ggplot2::ggplot_build(p))
})
