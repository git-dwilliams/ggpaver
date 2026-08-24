# TODO: Finish documentation for this file.
#' @rdname Stat
#' @format NULL
#' @usage NULL
#' @export
StatPavement <- ggplot2::ggproto(
  # StatPavement has much in common with StatBoxplot.
  "StatPavement",
  ggplot2::Stat,
  required_aes = "y|x",
  non_missing_aes = "weight",
  optional_aes = "width",
  dropped_aes = c("x", "y", "weight"),

  setup_data = function(self, data, params) {
    data <- ggplot2::flip_data(data, params$flipped_aes)
    data$x <- data$x %||% 0
    data <- ggplot2::remove_missing(
      data,
      na.rm = params$na.rm,
      vars = "x",
      name = "stat_pavement"
    )
    return(ggplot2::flip_data(data, params$flipped_aes))
  },

  setup_params = function(self, data, params) {
    params$flipped_aes <- ggplot2::has_flipped_aes(
      data,
      params,
      main_is_orthogonal = TRUE,
      group_has_equal = TRUE,
      main_is_optional = TRUE,
      default = NA
    )

    if (is.na(params$flipped_aes) && any(c("x", "y") %in% names(data))) {
      cli::cli_warn(
        "Orientation is not uniquely specified when both the x and y aesthetics are continuous. Picking default orientation 'x'."
      )
      params$flipped_aes <- FALSE
    }
    data <- ggplot2::flip_data(data, params$flipped_aes)

    has_x <- !(is.null(data$x) && is.null(params$x))
    has_y <- !(is.null(data$y) && is.null(params$y))
    if (!has_x && !has_y) {
      cli::cli_abort(
        "{.fn {snake_class(self)}} requires an {.field x} or {.field y} aesthetic."
      )
    }

    params$width <- params$width %||%
      (ggplot2::resolution(data$x %||% 0, discrete = TRUE) * 0.9)

    if (
      !is_mapped_discrete(data$x) &&
        is.double(data$x) &&
        !ggplot2::has_groups(data) &&
        any(data$x != data$x[1L])
    ) {
      cli::cli_warn(c(
        "Continuous {.field {flipped_names(params$flipped_aes)$x}} aesthetic",
        "i" = "did you forget {.code aes(group = ...)}?"
      ))
    }
    params$bins <- params$bins %||% 10
    if (
      !is.numeric(params$bins) || length(params$bins) != 1 || params$bins < 1
    ) {
      cli::cli_abort("{.arg bins} must be a single positive integer.")
    }
    params$bins <- as.integer(round(params$bins))

    return(params)
  },

  extra_params = c("na.rm", "orientation"),

  compute_group = function(
    data,
    scales,
    width = NULL,
    na.rm = FALSE,
    flipped_aes = FALSE,
    bins = 10,
    quantile.type = 7
  ) {
    data <- ggplot2::flip_data(data, flipped_aes)
    quantiles <- seq(0, 1, length.out = bins + 1)

    if (!is.null(data$weight)) {
      model <- quantreg::rq(
        y ~ 1,
        weights = weight,
        data = data,
        tau = quantiles
      )
      breaks <- as.numeric(stats::coef(model))
    } else {
      breaks <- as.numeric(stats::quantile(
        data$y,
        quantiles,
        type = quantile.type
      ))
    }

    breaks <- sort(unique(breaks))
    n_tiles <- length(breaks) - 1L

    # TODO: Currently, a user can construct a pavement plot with more tiles than
    # observations. This could potentially mislead. There should be at least
    # a warning indicating that the number of quantiles is greater than the
    # number of observations.
    if (n_tiles < 1L) {
      cli::cli_warn("Not enough distinct values to draw any pavement tiles.")
      return(vctrs::data_frame(.name_repair = "minimal"))
    }

    df <- vctrs::data_frame(
      ymin = breaks[seq_len(n_tiles)],
      ymax = breaks[seq_len(n_tiles) + 1L],
      .name_repair = "minimal"
    )

    df$count <- if (is.null(data$weight)) {
      length(data$y) / n_tiles
    } else {
      sum(data$weight, na.rm = TRUE) / n_tiles
    }
    df$density <- 1 / (df$ymax - df$ymin)

    df$x <- if (is.factor(data$x)) data$x[1] else mean(range(data$x))
    if (length(data$width) > 0L) {
      width <- data$width[1L]
    } else if (vctrs::vec_unique_count(data$x) > 1) {
      width <- diff(range(data$x)) * 0.9
    }
    df$width <- width
    df$flipped_aes <- flipped_aes

    ggplot2::flip_data(df, flipped_aes)
  }
)
#' @rdname geom_boxplot
#' @param quantile.type An integer between 1 and 9 setting the quantile
#'   algorithm per [`stats::quantile(type)`][stats::quantile]. Defaults to `7`.
#' @inheritParams shared_layer_parameters
#' @export
stat_pavement <- ggplot2::make_constructor(
  StatPavement,
  geom = "pavement",
  position = "identity",
  orientation = NA,
  omit = "width"
)
