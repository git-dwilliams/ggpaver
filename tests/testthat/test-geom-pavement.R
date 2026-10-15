# TODO: Finish tests. See test-geom-boxplot.R in ggplot2's repo.
test_that("geom_pavement works in both directions", {
  dat <- vctrs::data_frame(x = 1, y = c(-(1:20)^3, (1:20)^3))

  p <- ggplot2::ggplot(dat, ggplot2::aes(x, y)) + geom_pavement()
  x <- ggplot2::get_layer_data(p)
  expect_false(x$flipped_aes[1])

  p <- ggplot2::ggplot(dat, ggplot2::aes(y, x)) + geom_pavement()
  y <- ggplot2::get_layer_data(p)
  expect_true(y$flipped_aes[1])

  x$flipped_aes <- NULL
  y$flipped_aes <- NULL
  expect_identical(x, ggplot2::flip_data(y, TRUE))
})
