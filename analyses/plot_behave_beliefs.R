# ── Belief plots: manuscript figures 3A & 3B ──────────────────────────────────
# Plots subjective beliefs against model predictions and objective prevalence.
# Produces:
#   figures/fig7_beliefs_2x2.pdf
#   figures/beliefs_truth.pdf
#   figures/fig_belief_bar_truth.pdf
#
# Requires:
#   data/df_exp1.csv
#   data/model_df_exp1.csv
#   plot_themes.R, SEM.R

library(here)
library(ggplot2)
library(rlang)
library(dplyr)
library(patchwork)
library(reshape2)

source(here("plot_themes.R"))
source(here("SEM.R"))

dir.create(here("figures"), showWarnings = FALSE)

# ── Shared plot constants ──────────────────────────────────────────────────────
sem <- function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))

.cb_palette   <- c("#0072B2", "#E69F00", "#009E73")
.lwd_data     <- 3
.lwd_model    <- 2
.alpha_data   <- 0.9
.alpha_ribbon <- 0.28

# ── Plot function: belief vs model ─────────────────────────────────────────────
plot_beliefs <- function(data, x, y, a, b, sem, title = NULL) {
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
    ylim(0, 1) +
    xlab("\nTrial\n") +
    ylab("Prevalence of Gold\n") +
    ggtitle(title) +
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
          linewidth = c(.lwd_model, .lwd_data),
          alpha     = c(0.7, .alpha_data)
        )
      )
    )
}

# ── Plot function: belief vs objective prevalence ──────────────────────────────
plot_beliefs_truth <- function(data, x, y, a, b, sem, title = NULL) {
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
    ylim(0, 1) +
    xlab("\nTrial\n") +
    ylab("Prevalence of Gold\n") +
    ggtitle(title) +
    scale_linetype_manual(
      values = c("a" = "dotted", "b" = "solid"),
      labels = c("a" = "objective prevalence", "b" = "subjective belief"),
      name   = NULL
    ) +
    guides(
      alpha    = "none",
      size     = "none",
      fill     = "none",
      colour   = guide_legend(override.aes = list(linewidth = 3)),
      linetype = guide_legend(
        override.aes = list(
          linewidth = c(.lwd_model, .lwd_data),
          alpha     = c(0.7, .alpha_data)
        )
      )
    )
}

# ── Data prep: belief vs model ─────────────────────────────────────────────────
make_belief_df <- function(data_df, model_df, belief_col) {
  guess_cond <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = mean)
  guess_sem  <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = sem)
  names(guess_sem)[3] <- "SEM"

  model_cond <- aggregate(reformulate("trial_num + condition_txt", response = belief_col),
                          data = subset(model_df, ambig == 1), FUN = mean)
  colnames(model_cond)[2] <- "condition"

  out <- merge(guess_cond, model_cond)
  out <- merge(out, guess_sem)
  colnames(out) <- c("Trial", "Condition", "Data", "Model", "SEM")
  out
}

# ── Data prep: belief vs objective prevalence ──────────────────────────────────
make_belief_truth_df <- function(data_df) {
  guess_cond <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = mean)
  guess_sem  <- aggregate(guess_num ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = sem)
  names(guess_sem)[3] <- "SEM"

  feed_cond  <- aggregate((feedback > 0) ~ trial_num + condition,
                          data = subset(data_df, ambiguity == 1), FUN = mean)
  names(feed_cond)[3] <- "Truth"

  out <- merge(guess_cond, feed_cond)
  out <- merge(out, guess_sem)
  colnames(out) <- c("Trial", "Condition", "Data", "Truth", "SEM")
  out
}

# ── Load data ──────────────────────────────────────────────────────────────────
df       <- read.csv(here("data", "df_behav_exp1.csv"))
model_df <- read.csv(here("data", "model_df_exp1.csv"))

df$subject <- rep(seq_len(length(unique(df$subject_id))), each = 60)

model_df <- model_df %>%
  rowwise() %>%
  mutate(
    Highest_Value = max(
      pxp_bayes_1prior, pxp_bayes_1prior_skip, pxp_1lr_skip,
      pxp_bayes_3prior_skip, pxp_bayes_3prior,
      pxp_2lr_skip, pxp_2lr_bias, pxp_2lr_skip_3q, pxp_2lr_bias_3q
    ),
    win_model = case_when(
      Highest_Value == pxp_bayes_1prior      ~ "bayes_1prior",
      Highest_Value == pxp_bayes_1prior_skip ~ "bayes_1prior_skip",
      Highest_Value == pxp_1lr_skip          ~ "1lr_skip",
      Highest_Value == pxp_bayes_3prior_skip ~ "bayes_3prior_skip",
      Highest_Value == pxp_bayes_3prior      ~ "bayes_3prior",
      Highest_Value == pxp_2lr_skip          ~ "2lr_skip",
      Highest_Value == pxp_2lr_bias          ~ "2lr_bias",
      Highest_Value == pxp_2lr_skip_3q       ~ "2lr_skip_3q",
      Highest_Value == pxp_2lr_bias_3q       ~ "2lr_bias_3q",
      TRUE                                   ~ NA_character_
    )
  ) %>%
  ungroup()

# ── Fig 7: belief vs model (2x2) ──────────────────────────────────────────────
df_A <- make_belief_df(df, model_df, "p_belief_bayes_1prior")
plot_A <- plot_beliefs(df_A, Trial, Condition, Model, Data, SEM,
                       title = "One-prior Bayesian Model")

sub_model_1 <- model_df %>% filter(win_model == "bayes_1prior")
sub_data_1  <- df %>% semi_join(sub_model_1, by = "subject")
df_B        <- make_belief_df(sub_data_1, sub_model_1, "p_belief_bayes_1prior")
plot_B      <- plot_beliefs(df_B, Trial, Condition, Model, Data, SEM, title = NULL)

df_C   <- make_belief_df(df, model_df, "p_belief_bayes_3prior")
plot_C <- plot_beliefs(df_C, Trial, Condition, Model, Data, SEM,
                       title = "Three-prior Bayesian Model")

sub_model_3 <- model_df %>% filter(win_model == "bayes_3prior")
sub_data_3  <- df %>% semi_join(sub_model_3, by = "subject")
df_D        <- make_belief_df(sub_data_3, sub_model_3, "p_belief_bayes_3prior")
plot_D      <- plot_beliefs(df_D, Trial, Condition, Model, Data, SEM, title = NULL)

fig7 <- (plot_A + plot_C) / (plot_B + plot_D) +
  plot_layout(guides = "collect") &
  theme4

ggsave(here("figures", "fig7_beliefs_2x2.pdf"), fig7, width = 36, height = 20)

# ── Belief vs objective prevalence ────────────────────────────────────────────
df_truth  <- make_belief_truth_df(df)
plot_truth <- plot_beliefs_truth(df_truth, Trial, Condition,
                                 a = Truth, b = Data, sem = SEM)
plot_truth + theme4a

ggsave(here("figures", "beliefs_truth.pdf"),
       plot_truth + theme4, width = 18, height = 10)

# ── Bar plot: belief by feedback type x condition ─────────────────────────────
meltDF <- melt(df,
               id.vars      = c("feedback_image", "condition", "subject_id"),
               measure.vars = "guess_num")

meltDFcalc <- summarySEwithin(meltDF, measurevar = "value",
                               withinvars = c("feedback_image", "condition"),
                               idvar = "subject_id", na.rm = TRUE)

model_df <- model_df %>%
  dplyr::mutate(feedback_bin = dplyr::case_when(
    feedback_shown > 0 & ambig == 0 ~ "Gold",
    feedback_shown < 0 & ambig == 0 ~ "Rocks",
    ambig == 1                      ~ "Dirty"
  ))

meltDF1 <- melt(model_df,
                id.vars      = c("feedback_bin", "condition_txt", "subject"),
                measure.vars = "p_belief_bayes_3prior")

meltDFcalc1 <- summarySEwithin(meltDF1, measurevar = "value",
                                withinvars = c("feedback_bin", "condition_txt"),
                                idvar = "subject", na.rm = TRUE)
colnames(meltDFcalc1)[1:2] <- c("feedback_image", "condition")

plot_bar <- ggplot(meltDFcalc,
                   aes(x = condition, y = value, fill = factor(feedback_image))) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_errorbar(aes(ymin = value - se, ymax = value + se),
                width = 0.05, linewidth = 0.8,
                position = position_dodge(0.9),
                colour = "gray30") +
  geom_errorbar(data = meltDFcalc1,
                aes(x = condition, y = value,
                    ymin = value, ymax = value,
                    group = feedback_image,
                    linetype = "model"),
                width = 0.6, linewidth = 2.5, alpha = 0.5,
                colour = "turquoise",
                position = position_dodge(0.9)) +
  scale_fill_manual(
    name   = "Feedback",
    values = c("Dirty" = "tan", "Gold" = "lightgoldenrod1", "Rocks" = "seashell4")
  ) +
  scale_linetype_manual(
    values = c("model" = "solid"),
    labels = c("model" = "model predicted beliefs"),
    name   = NULL
  ) +
  xlab("\nCondition") +
  ylab("Belief in Gold\n") +
  guides(
    fill     = guide_legend(override.aes = list(shape = NA)),
    linetype = guide_legend(override.aes = list(
      colour    = "turquoise",
      linewidth = 2.5,
      alpha     = 0.5
    ))
  )

# ── Combined figure: bar + belief vs truth ────────────────────────────────────
df_truth   <- make_belief_truth_df(df)
plot_truth <- plot_beliefs_truth(df_truth, Trial, Condition,
                                 a = Truth, b = Data, sem = SEM)

fig_combined <- ((plot_bar + theme4) | (plot_truth + theme4)) +
  plot_layout(widths = c(2, 2))

ggsave(here("figures", "fig_belief_bar_truth.pdf"),
       fig_combined, width = 42, height = 12, dpi = 300)
