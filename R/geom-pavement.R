# TODO: Finish documentation
#' A pavement plot
#'
#' The pavement plot presents a continuous variable's distribution in a manner
#' similar to that of a boxplot, but with greater flexibilitiy. While
#' `ggplot2::stat_boxplot` calculates fixed quantiles `c(0, 0.25, 0.5, 0.75, 1)`,
#' `stat_pavement` calculates quantiles as split by parameter that the user
#' gives for the `bins` argument.
#'
#' @aesthetics GeomPavement
#'
#' @export
#' @examples
#' ggplot2::ggplot(penguins, ggplot2::aes(body_mass, species)) + geom_pavement()
#' # Orientation is switchable. Having the continuous variable on the x-axis
#' # is recommended.
#' ggplot2::ggplot(penguins, ggplot2::aes(species, body_mass)) + geom_pavement()
geom_pavement <- function(
  mapping = NULL,
  data = NULL,
  stat = "pavement",
  position = "identity",
  ...,
  bins = 4,
  quantile.type = 2,
  na.rm = FALSE,
  orientation = NA,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomPavement,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      bins = bins,
      quantile.type = quantile.type,
      na.rm = na.rm,
      orientation = orientation,
      ...
    )
  )
}


GeomPavement <- ggplot2::ggproto(
  "GeomPavement",
  ggplot2::Geom,
  extra_params = c("na.rm", "orientation"),

  setup_params = function(data, params) {
    params$flipped_aes <- ggplot2::has_flipped_aes(data, params)
    params
  },

  setup_data = function(self, data, params) {
    data$flipped_aes <- params$flipped_aes
    data <- ggplot2::flip_data(data, params$flipped_aes)
    data$width <- data$width %||% params$width %||% self$default_aes$width

    units <- unique(data[c("x", "group")])
    units <- units[order(units$x, units$group), ]
    units$n <- ave(units$group, units$x, FUN = length)
    units$idx <- unlist(lapply(split(seq_len(nrow(units)), units$x), seq_along))

    key <- match(paste(data$x, data$group), paste(units$x, units$group))
    n <- units$n[key]
    idx <- units$idx[key]

    col_width <- data$width / n
    data$x <- data$x + (idx - (n + 1) / 2) * col_width
    data$xmin <- data$x - col_width / 2
    data$xmax <- data$x + col_width / 2
    data$width <- NULL

    ggplot2::flip_data(data, params$flipped_aes)
  },

  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    lineend = "butt",
    linejoin = "mitre",
    flipped_aes = FALSE
  ) {
    ggplot2::GeomRect$draw_panel(
      data,
      panel_params,
      coord,
      lineend = lineend,
      linejoin = linejoin
    )
  },

  draw_key = ggplot2::draw_key_polygon,

  default_aes = ggplot2::aes(
    colour = "black",
    fill = "white",
    linewidth = 0.5,
    linetype = 1,
    alpha = NA,
    width = 0.9
  ),

  required_aes = c("x|y", "ymin|xmin", "ymax|xmax")
)
