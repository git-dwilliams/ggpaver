# TODO: Finish documentation for this file.
geom_pavement <- function(
  mapping = NULL,
  data = NULL,
  stat = "pavement",
  position = "identity",
  ...,
  bins = 10,
  quantile.type = 7,
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


#' @rdname Geom
#' @format NULL
#' @usage NULL
#' @export
GeomPavement <- ggplot2::ggproto(
  "GeomPavement",
  ggplot2::Geom,
  extra_params = c("na.rm", "orientation"),

  setup_params = function(data, params) {
    params$flipped_aes <- ggplot2::has_flipped_aes(data, params)
    params
  },

  # TODO: Refactor `setup_data` method in order to more idiomatic and in line
  # with that of other Geoms.
  setup_data = function(self, data, params) {
    data$flipped_aes <- params$flipped_aes
    data <- ggplot2::flip_data(data, params$flipped_aes)
    data$width <- data$width %||% params$width %||% self$default_aes$width

    units <- unique(data[c("x", "group")])
    units <- units[order(units$x, units$group), ]
    # how many columns share each nominal x, and this column's rank
    # among them, left to right
    units$n <- ave(units$group, units$x, FUN = length)
    units$idx <- unlist(lapply(split(seq_len(nrow(units)), units$x), seq_along))

    key <- match(paste(data$x, data$group), paste(units$x, units$group))
    n <- units$n[key]
    idx <- units$idx[key]

    # Shrink each column to its even share of the slot and centre columns
    # symmetrically either side of the nominal x -- the same arithmetic
    # position_dodge2() applies, just computed once per column rather
    # than once per row, so every slab in a column moves together.
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
