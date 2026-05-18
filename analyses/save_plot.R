# ── save_plot: convenience wrapper around ggsave ──────────────────────────────
# Saves a ggplot object with a theme applied to a file.
#
# Usage:
#   save_plot(plot_obj, here("figures", "my_plot.pdf"), theme4a, width = 24, height = 12)
#
# Arguments:
#   plotname  : a ggplot object
#   filename  : full output path (use here() to build it)
#   plottheme : a ggplot theme object (e.g. theme4a from plot_themes.R)
#   w         : output width in inches
#   h         : output height in inches

save_plot <- function(plotname, filename, plottheme, w, h) {
  ggsave(filename, plotname + plottheme, width = w, height = h)
}
