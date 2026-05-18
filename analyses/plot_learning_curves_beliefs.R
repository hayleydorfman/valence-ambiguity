# ── Learning curves and belief plots ──────────────────────────────────────────
# Plots choice accuracy learning curves and belief trajectories over trials,
# comparing subject data to model predictions.
# Produces:
#   figures/learning_curves.pdf
#   figures/beliefs_5panel_p16.pdf
#
# Requires:
#   data/df_numeric_pilot_16_acc.csv
#   data/model_df_p16_exp56.csv
#   plot_themes.R, save_plot.R, SEM.R

library(here)

# plyr must be loaded before dplyr to avoid namespace conflicts
if ("dplyr" %in% (.packages())) {
  detach("package:dplyr", unload = TRUE)
  detach("package:plyr",  unload = TRUE)
}
library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(rlang)
library(patchwork)
library(egg)
library(gridExtra)
library(grid)

source(here("plot_themes.R"))
source(here("save_plot.R"))
source(here("SEM.R"))

dir.create(here("figures"), showWarnings = FALSE)

# ── Shared constants ───────────────────────────────────────────────────────────
sem <- function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))

.cb_palette       <- c("#0072B2", "#E69F00", "#009E73")
.lwd_data         <- 3
.lwd_model        <- 2
.alpha_data       <- 0.9
.alpha_ribbon     <- 0.28
.lwd_data_belief  <- 1.5
.lwd_model_belief <- 1.0

# ── Plot functions ─────────────────────────────────────────────────────────────

# Learning curves: choice accuracy by trial and condition
plot_learning_curves <- function(data, x, y, a, b, sem) {
  ggplot(data = data,
         aes(x = {{ x }}, col = {{ y }}, fill = {{ y }})) +
    scale_x_continuous(breaks = seq(2, 10, by = 2)) +
    geom_ribbon(aes(ymin = {{ b }} - {{ sem }},
                    ymax = {{ b }} + {{ sem }}),
                alpha = .alpha_ribbon, colour = NA) +
    geom_line(aes(y = {{ b }}, linetype = "b"),
              linewidth = .lwd_data, alpha = .alpha_data) +
    geom_line(aes(y = {{ a }}, linetype = "a"),
              linewidth = .lwd_model, alpha = 0.7) +
    scale_color_manual(values = .cb_palette, name = NULL) +
    scale_fill_manual(values  = .cb_palette, name = NULL) +
    ylim(0.4, 1) +
    xlab("\nTrial\n") +
    ylab("Choice Accuracy\n(% optimal choice)\n") +
    scale_linetype_manual(
      values = c("a" = "dashed", "b" = "solid"),
      labels = c("a" = "model",  "b" = "data"),
      name   = NULL
    ) +
    guides(
      alpha    = "none",
      size     = "none",
      fill     = "none",
      colour   = "none",
      linetype = guide_legend(
        override.aes = list(
          linewidth = c(.lwd_model, .lwd_data),
          alpha     = c(0.7, .alpha_data)
        )
      )
    ) +
    facet_wrap(vars({{ y }}))
}

# Belief curves: subjective gold prevalence by trial and condition (Bayesian models)
plot_beliefs <- function(data, x, y, a, b, sem) {
  ggplot(data = data,
         aes(x = {{ x }}, col = {{ y }}, fill = {{ y }})) +
    scale_x_continuous(breaks = seq(2, 10, by = 2)) +
    geom_ribbon(aes(ymin = {{ b }} - {{ sem }},
                    ymax = {{ b }} + {{ sem }}),
                alpha = .alpha_ribbon, colour = NA) +
    geom_line(aes(y = {{ b }}, linetype = "b"),
              linewidth = .lwd_data_belief, alpha = .alpha_data) +
    geom_line(aes(y = {{ a }}, linetype = "a"),
              linewidth = .lwd_model_belief, alpha = 0.7) +
    scale_color_manual(values = .cb_palette, name = NULL) +
    scale_fill_manual(values  = .cb_palette, name = NULL) +
    ylim(0, 1) +
    xlab("\nTrial\n") +
    ylab("Prevalence of Gold\n") +
    scale_linetype_manual(
      values = c("a" = "dashed", "b" = "solid"),
      labels = c("a" = "model",  "b" = "data"),
      name   = NULL
    ) +
    guides(
      alpha    = "none",
      size     = "none",
      fill     = "none",
      colour   = guide_legend(override.aes = list(linewidth = 3)),
      linetype = guide_legend(
        override.aes = list(
          linewidth = c(.lwd_model_belief, .lwd_data_belief),
          alpha     = c(0.7, .alpha_data)
        )
      )
    )
}

# Belief curves variant for RL models
plot_beliefs_rl <- function(data, x, y, a, b, sem) {
  ggplot(data = data,
         aes(x = {{ x }}, col = {{ y }}, fill = {{ y }})) +
    scale_x_continuous(breaks = seq(2, 10, by = 2)) +
    geom_ribbon(aes(ymin = {{ b }} - {{ sem }},
                    ymax = {{ b }} + {{ sem }}),
                alpha = .alpha_ribbon, colour = NA) +
    geom_line(aes(y = {{ b }}, linetype = "b"),
              linewidth = .lwd_data_belief, alpha = .alpha_data) +
    geom_line(aes(y = {{ a }}, linetype = "a"),
              linewidth = .lwd_model_belief, alpha = 0.7) +
    scale_color_manual(values = .cb_palette, name = NULL) +
    scale_fill_manual(values  = .cb_palette, name = NULL) +
    ylim(0, 1) +
    xlab("\nTrial\n") +
    ylab("Prevalence of Gold\n") +
    scale_linetype_manual(
      values = c("a" = "dashed", "b" = "solid"),
      labels = c("a" = "model", "b" = "data"),
      name   = NULL
    ) +
    guides(
      alpha    = "none",
      size     = "none",
      fill     = "none",
      colour   = guide_legend(override.aes = list(linewidth = 3)),
      linetype = guide_legend(
        override.aes = list(
          linewidth = c(.lwd_model_belief, .lwd_data_belief),
          alpha     = c(0.7, .alpha_data)
        )
      )
    )
}

# ── Helper: aggregate beliefs + SEM, merge with model ─────────────────────────
make_belief_df <- function(data_df, model_df, belief_col) {
  guess_cond <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = mean)
  guess_sem  <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = sem)
  names(guess_sem)[3] <- "SEM"

  model_cond <- aggregate(reformulate("trial_num + condition_txt", response = belief_col),
                          data = subset(model_df, ambig == 1), FUN = mean)
  colnames(model_cond)[2] <- "condition"

  out           <- merge(guess_cond, model_cond)
  out           <- merge(out, guess_sem)
  colnames(out) <- c("Trial", "Condition", "Data", "Model", "SEM")
  out$Trial     <- as.numeric(as.character(out$Trial))
  out$Condition <- factor(out$Condition, levels = c("neutral", "poor", "rich"))
  out
}

# ── Load data ──────────────────────────────────────────────────────────────────
# model_df_p16_exp56.csv is the pre-processed model output file.
# It was originally produced from raw MATLAB output files; the processed version
# is provided directly so users do not need to re-run the MATLAB pipeline.

model_df <- read.csv(here("data", "model_df_p16_exp56.csv"))
df       <- read.csv(here("data", "df_numeric_pilot_16_acc.csv"))

df$subject <- rep(seq_len(length(unique(df$subject_id))), each = 60)

# Ensure factor types are correct for downstream aggregation
model_df$condition_txt <- as.factor(model_df$condition_txt)
model_df$trial_num     <- as.factor(model_df$trial_num)

# ── Learning curves ────────────────────────────────────────────────────────────
model_summary <- model_df %>%
  dplyr::group_by(trial_num, condition_txt) %>%
  dplyr::summarise(model_value = mean(model_accuracy), .groups = "drop") %>%
  dplyr::rename(Trial = trial_num, Condition = condition_txt) %>%
  dplyr::mutate(Trial = as.numeric(as.character(Trial)))

subj_summary <- df %>%
  dplyr::group_by(trial_num, condition) %>%
  dplyr::summarise(
    subj_value = mean(choice_accuracy, na.rm = TRUE),
    sem        = sem(choice_accuracy),
    .groups    = "drop"
  ) %>%
  dplyr::rename(Trial = trial_num, Condition = condition) %>%
  dplyr::mutate(Trial = as.numeric(as.character(Trial)))

both_df <- merge(model_summary, subj_summary, by = c("Trial", "Condition"))

prettyplot3 <- plot_learning_curves(both_df, Trial, Condition,
                                    a = model_value, b = subj_value, sem = sem)
prettyplot3 + theme4
save_plot(prettyplot3, here("figures", "learning_curves.pdf"), theme4, 30, 10)

# ── Belief curves ──────────────────────────────────────────────────────────────

# Identify winning model per subject
model_df <- model_df %>%
  rowwise() %>%
  mutate(
    Highest_Value = max(
      pxp_bayes_1prior, pxp_bayes_1prior_skip, pxp_1lr_skip,
      pxp_bayes_3prior_skip, pxp_bayes_3prior,
      pxp_2lr_skip, pxp_2lr_bias, pxp_2lr_skip_3q, pxp_2lr_bias_3q,
      pxp_2lr_confirm
    ),
    win_model = case_when(
      Highest_Value == pxp_bayes_1prior      ~ "bayes_1prior",
      Highest_Value == pxp_bayes_1prior_skip ~ "bayes_1prior_skip",
      Highest_Value == pxp_1lr_skip          ~ "1lr_skip",
      Highest_Value == pxp_bayes_3prior_skip ~ "bayes_3prior_skip",
      Highest_Value == pxp_bayes_3prior      ~ "bayes_3prior",
      Highest_Value == pxp_2lr_skip          ~ "2lr_skip",
      Highest_Value == pxp_2lr_bias          ~ "2lr_bias",
      Highest_Value == pxp_2lr_confirm       ~ "2lr_confirm",
      Highest_Value == pxp_2lr_skip_3q       ~ "2lr_skip_3q",
      Highest_Value == pxp_2lr_bias_3q       ~ "2lr_bias_3q",
      TRUE                                   ~ NA_character_
    )
  ) %>%
  ungroup()

# Subsets by winning model
subset_1prior  <- model_df %>% filter(win_model == "bayes_1prior")
df_data_1prior <- df %>% semi_join(subset_1prior, by = "subject")
n_1prior       <- length(unique(subset_1prior$subject))

subset_3prior  <- model_df %>% filter(win_model == "bayes_3prior")
df_data_3prior <- df %>% semi_join(subset_3prior, by = "subject")
n_3prior       <- length(unique(subset_3prior$subject))

# Build all five belief dataframes
df_A <- make_belief_df(df,            model_df,       "p_belief_bayes_1prior")
df_B <- make_belief_df(df_data_1prior, subset_1prior, "p_belief_bayes_1prior")
df_C <- make_belief_df(df,            model_df,       "p_belief_bayes_3prior")
df_D <- make_belief_df(df_data_3prior, subset_3prior, "p_belief_bayes_3prior")
df_E <- make_belief_df(df,            model_df,       "p_belief_2lr_bias_3Q")

# ── Theme for multipanel figure ────────────────────────────────────────────────
theme_5panel <- theme(
  panel.border     = element_rect(colour = "gray22", fill = NA),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  axis.line        = element_line(color = "gray22"),
  axis.text.y      = element_text(size = 14, family = "Helvetica", margin = margin(r = 5)),
  axis.text.x      = element_text(size = 14, vjust = 0.5, family = "Helvetica"),
  axis.title.y     = element_text(size = 16, vjust = 0.8, family = "Helvetica"),
  axis.title.x     = element_text(size = 16, family = "Helvetica"),
  title            = element_text(size = 15, color = "#3F4042", face = "bold", family = "Helvetica"),
  panel.background = element_rect(fill = "white"),
  legend.key.size  = unit(0.8, "cm"),
  legend.text      = element_text(size = 13, family = "Helvetica"),
  legend.title     = element_blank(),
  legend.key       = element_rect(fill = "white", colour = "grey95"),
  plot.margin      = unit(c(0.4, 0.4, 0.4, 0.4), "cm")
)

no_leg <- theme(legend.position = "none")

pA <- plot_beliefs(df_A, Trial, Condition, Model, Data, SEM) + theme_5panel + no_leg
pB <- plot_beliefs(df_B, Trial, Condition, Model, Data, SEM) + theme_5panel + no_leg
pC <- plot_beliefs(df_C, Trial, Condition, Model, Data, SEM) + theme_5panel + no_leg
pD <- plot_beliefs(df_D, Trial, Condition, Model, Data, SEM) + theme_5panel + no_leg
pE <- plot_beliefs_rl(df_E, Trial, Condition, Model, Data, SEM) + theme_5panel + no_leg

# Extract shared legend from panel A
get_legend <- function(p) {
  g   <- ggplot_gtable(ggplot_build(p))
  leg <- which(sapply(g$grobs, function(x) x$name) == "guide-box")
  g$grobs[[leg]]
}

legend_source  <- plot_beliefs(df_A, Trial, Condition, Model, Data, SEM) +
  theme_5panel + theme(legend.position = "right")
shared_legend  <- get_legend(legend_source)

# Align panels with egg, add legend with gridExtra
aligned <- egg::ggarrange(pA, pC, pE, pB, pD,
                          ncol = 3, nrow = 2,
                          labels     = c("A", "B", "C", "D", "E"),
                          label.args = list(gp = grid::gpar(fontface = "bold", cex = 1.2)))

final <- gridExtra::arrangeGrob(
  aligned, shared_legend,
  ncol   = 2,
  widths = c(0.85, 0.15)
)

ggsave(here("figures", "beliefs_5panel_p16.pdf"),
       final, width = 44, height = 22, units = "cm")
