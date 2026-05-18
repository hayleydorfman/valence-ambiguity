# ── Plot themes ────────────────────────────────────────────────────────────────
# Defines all ggplot2 themes used across plotting scripts.
# Source this file at the top of any plotting script with:
#   source(here("plot_themes.R"))

library(ggplot2)
library(RColorBrewer)
library(grid)

# ── Color palette ──────────────────────────────────────────────────────────────
my_colors <- brewer.pal(5, "Spectral")
my_colors <- colorRampPalette(my_colors)(100)


# ── theme_scatter: scatterplot with regression line ────────────────────────────
theme_scatter <- theme(
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 40, family = "Helvetica"),
  axis.text.x       = element_text(size = 40, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 50, vjust = 2, family = "Helvetica"),
  axis.title.x      = element_text(size = 50, vjust = 2, family = "Helvetica"),
  title             = element_text(size = 50, color = "#3F4042", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(5, "lines"),
  legend.text       = element_text(size = 40, family = "Helvetica", color = "gray22"),
  legend.title      = element_text(size = 32, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme_box: boxplot ─────────────────────────────────────────────────────────
theme_box <- theme(
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 40, family = "Helvetica"),
  axis.text.x       = element_text(size = 40, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 50, vjust = 2, family = "Helvetica"),
  axis.title.x      = element_blank(),
  title             = element_text(size = 50, color = "#3F4042", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(3, "lines"),
  legend.text       = element_blank(),
  legend.title      = element_blank(),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  legend.position   = "none"
)


# ── theme_bar: barplot ─────────────────────────────────────────────────────────
theme_bar <- theme(
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 40, family = "Helvetica"),
  axis.text.x       = element_text(size = 40, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 50, vjust = 2, family = "Helvetica"),
  axis.title.x      = element_text(size = 50, vjust = 2, family = "Helvetica"),
  title             = element_text(size = 50, color = "#3F4042", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(5, "lines"),
  legend.text       = element_text(size = 32, family = "Helvetica", color = "gray22"),
  legend.title      = element_text(size = 40, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme1: general barplot ────────────────────────────────────────────────────
theme1 <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 30, family = "Helvetica"),
  axis.text.x       = element_text(size = 30, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 30, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 30, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(2, "cm"),
  legend.text       = element_text(size = 30, family = "Helvetica"),
  legend.title      = element_text(size = 32, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text        = element_text(size = 25)
)


# ── theme1c: theme1 without x-axis text ───────────────────────────────────────
theme1c <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 30, family = "Helvetica"),
  axis.text.x       = element_blank(),
  axis.title.y      = element_text(size = 30, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 30, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(2, "cm"),
  legend.text       = element_text(size = 30, family = "Helvetica"),
  legend.title      = element_text(size = 32, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme1A: barplot for presentations (larger text) ──────────────────────────
theme1A <- theme(
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 40, family = "Helvetica"),
  axis.text.x       = element_text(size = 40, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 2, family = "Helvetica"),
  axis.title.x      = element_text(size = 40, vjust = 2, family = "Helvetica"),
  title             = element_text(size = 30, color = "#3F4042", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(0.5, "cm"),
  legend.text       = element_text(size = 30, family = "Helvetica", color = "gray22"),
  legend.title      = element_text(size = 32, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme1B: theme1A with panel border and gridlines ──────────────────────────
theme1B <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 40, family = "Helvetica"),
  axis.text.x       = element_text(size = 40, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 2, family = "Helvetica"),
  axis.title.x      = element_text(size = 40, vjust = 2, family = "Helvetica"),
  title             = element_text(size = 30, color = "#3F4042", family = "Helvetica"),
  legend.key.size   = unit(0.5, "cm"),
  legend.text       = element_text(size = 30, family = "Helvetica", color = "gray22"),
  legend.title      = element_text(size = 32, family = "Helvetica"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme2: boxplot (smaller text) ────────────────────────────────────────────
theme2 <- theme(
  panel.border      = element_rect(colour = "gray", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "black"),
  axis.text.y       = element_text(size = 26, family = "Helvetica"),
  axis.text.x       = element_text(size = 26, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 26, vjust = 0.8, family = "Helvetica"),
  title             = element_text(margin = margin(0, 20, 0, 0), size = 26, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(2, "cm"),
  legend.text       = element_text(size = 16, family = "Helvetica"),
  legend.title      = element_text(size = 18, family = "Helvetica")
)


# ── theme2A: theme2 without x-axis title ──────────────────────────────────────
theme2A <- theme(
  panel.border      = element_rect(colour = "gray", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "black"),
  axis.text.y       = element_text(size = 26, family = "Helvetica"),
  axis.text.x       = element_text(size = 26, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 26, vjust = 0.8, family = "Helvetica"),
  axis.title.x      = element_blank(),
  title             = element_text(margin = margin(0, 20, 0, 0), size = 26, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.position   = "none"
)


# ── theme3: muted/grey presentation style ─────────────────────────────────────
theme3 <- theme(
  panel.border      = element_rect(colour = "#918485", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "#918485"),
  axis.text.y       = element_text(size = 30, family = "Helvetica", color = "#918485"),
  axis.text.x       = element_text(size = 30, vjust = 0.5, family = "Helvetica", color = "#918485"),
  axis.title.y      = element_text(size = 30, vjust = 0.8, family = "Helvetica", color = "#918485"),
  title             = element_text(size = 30, color = "#918485", family = "Helvetica"),
  panel.background  = element_rect(fill = "#EBECED"),
  legend.key.size   = unit(2, "cm"),
  legend.text       = element_text(size = 20, family = "Helvetica", color = "#918485"),
  legend.title      = element_text(size = 22, family = "Helvetica", color = "#918485"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm")
)


# ── theme4: manuscript figures (large text, subtle gridlines) ─────────────────
theme4 <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 45, family = "Helvetica"),
  axis.text.x       = element_text(size = 45, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 50, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 50, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(1.8, "cm"),
  legend.text       = element_text(size = 35, family = "Helvetica"),
  legend.title      = element_text(size = 35, family = "Helvetica"),
  legend.key        = element_rect(fill = "white", colour = "grey95"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text.x      = element_text(size = 45)
)


# ── theme4a: theme4 with visible gridlines ─────────────────────────────────────
theme4a <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_line(color = "grey90", linewidth = 0.25),
  panel.grid.minor  = element_line(color = "grey95", linewidth = 0.25),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 35, family = "Helvetica"),
  axis.text.x       = element_text(size = 35, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 40, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(1.8, "cm"),
  legend.text       = element_text(size = 30, family = "Helvetica"),
  legend.title      = element_text(size = 30, family = "Helvetica"),
  legend.key        = element_rect(fill = "white", colour = "grey95"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text.x      = element_text(size = 45)
)


# ── theme4b: theme4a with smaller axis text ────────────────────────────────────
theme4b <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_line(color = "grey90", linewidth = 0.25),
  panel.grid.minor  = element_line(color = "grey95", linewidth = 0.25),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 23, family = "Helvetica"),
  axis.text.x       = element_text(size = 23, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 40, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(1.8, "cm"),
  legend.text       = element_text(size = 20, family = "Helvetica"),
  legend.title      = element_text(size = 22, family = "Helvetica"),
  legend.key        = element_rect(fill = "white", colour = "grey95"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text.x      = element_text(size = 45)
)


# ── theme5: smaller text, for dense multipanel figures ────────────────────────
theme5 <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 20, family = "Helvetica"),
  axis.text.x       = element_text(size = 20, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 40, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.key.size   = unit(1, "cm"),
  legend.text       = element_text(size = 20, family = "Helvetica"),
  legend.title      = element_text(size = 20, family = "Helvetica"),
  legend.key        = element_rect(fill = "white", colour = "grey95"),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text.x      = element_text(size = 30)
)


# ── theme6: no legend ─────────────────────────────────────────────────────────
theme6 <- theme(
  panel.border      = element_rect(colour = "gray22", fill = NA),
  panel.grid.major  = element_blank(),
  panel.grid.minor  = element_blank(),
  axis.line         = element_line(color = "gray22"),
  axis.text.y       = element_text(size = 20, family = "Helvetica"),
  axis.text.x       = element_text(size = 20, vjust = 0.5, family = "Helvetica"),
  axis.title.y      = element_text(size = 40, vjust = 0.8, family = "Helvetica"),
  title             = element_text(size = 40, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background  = element_rect(fill = "white"),
  legend.title      = element_blank(),
  legend.key        = element_blank(),
  legend.text       = element_blank(),
  plot.margin       = unit(c(1, 1, 1, 1), units = "cm"),
  strip.text.x      = element_text(size = 30)
)


# ── theme7: minimal with gridlines ────────────────────────────────────────────
theme7 <- theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "grey90", linewidth = 0.5),
    panel.grid.minor = element_line(color = "grey95", linewidth = 0.25),
    axis.text.x      = element_text(size = 35, hjust = 1),
    axis.text.y      = element_text(size = 35),
    axis.title       = element_text(size = 40),
    legend.position  = "right",
    legend.text      = element_text(size = 30),
    legend.title     = element_blank()
  )
