# ── Model comparison plots (PXP and AIC) ──────────────────────────────────────
# Produces two figures:
#   figures/pxp_probs.pdf       – stacked bar of protected exceedance probabilities
#   figures/aic_means.pdf       – mean AIC with error bars
#   figures/fig6_model_comparison.pdf – combined manuscript figure 6
#
# Requires:
#   data/model_df_p16_exp56.csv
#   plot_themes.R, save_plot.R, SEM.R

library(here)
library(dplyr)
library(tidyr)
library(ggplot2)

source(here("plot_themes.R"))
source(here("save_plot.R"))
source(here("SEM.R"))

dir.create(here("figures"), showWarnings = FALSE)

# ── Standard error helper ──────────────────────────────────────────────────────
sem <- function(x) sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))

# ── Load data ──────────────────────────────────────────────────────────────────
model_df <- read.csv(here("data", "model_df_p16_exp56.csv"))

# ── Identify winning model per subject ────────────────────────────────────────
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

df <- model_df[!duplicated(model_df$subject), ]
table(df$win_model)

# ── Shared order, labels, and colors ──────────────────────────────────────────
pxp_breaks <- c(
  "pxp_1lr_skip",
  "pxp_2lr_skip",
  "pxp_2lr_confirm",
  "pxp_2lr_bias",
  "pxp_2lr_skip_3q",
  "pxp_2lr_bias_3q",
  "pxp_bayes_1prior_skip",
  "pxp_bayes_1prior",
  "pxp_bayes_3prior_skip",
  "pxp_bayes_3prior"
)

pxp_labels <- c(
  "pxp_1lr_skip"          = "1-learning rate",
  "pxp_2lr_skip"          = "2-learning rate",
  "pxp_2lr_confirm"       = "2-learning rate (confirm)",
  "pxp_2lr_bias"          = "2-learning rate (bias)",
  "pxp_2lr_skip_3q"       = "2-learning rate (init)",
  "pxp_2lr_bias_3q"       = "2-learning rate (bias+init)",
  "pxp_bayes_1prior_skip" = "1-prior Bayes (skip)",
  "pxp_bayes_1prior"      = "1-prior Bayes",
  "pxp_bayes_3prior_skip" = "3-prior Bayes (skip)",
  "pxp_bayes_3prior"      = "3-prior Bayes"
)

pxp_colors <- c(
  "pxp_1lr_skip"          = "#9D2E06",
  "pxp_2lr_skip"          = "#ED8D6B",
  "pxp_2lr_confirm"       = "#F27D52",
  "pxp_2lr_bias"          = "#FC723F",
  "pxp_2lr_skip_3q"       = "#E64105",
  "pxp_2lr_bias_3q"       = "#FCC7B3",
  "pxp_bayes_1prior_skip" = "#67ABF0",
  "pxp_bayes_1prior"      = "#BAD6F3",
  "pxp_bayes_3prior_skip" = "#2281E0",
  "pxp_bayes_3prior"      = "#0E569E"
)

# ── PXP stacked bar plot ───────────────────────────────────────────────────────
df_sorted         <- df %>% arrange(desc(pxp_bayes_3prior))
df_sorted$subject <- seq_len(nrow(df_sorted))

df_long_pxp <- df_sorted %>%
  tidyr::pivot_longer(cols = starts_with("pxp"),
                      names_to  = "component",
                      values_to = "proportion") %>%
  filter(component %in% pxp_breaks) %>%
  mutate(
    subject   = as.numeric(as.character(subject)),
    component = factor(component, levels = pxp_breaks)
  )

plot_pxp <- ggplot(df_long_pxp, aes(x = subject, y = proportion, fill = component)) +
  geom_bar(stat = "identity") +
  scale_x_continuous(
    breaks = c(10, 20, 30, 40, 50, 60),
    labels = c("10", "20", "30", "40", "50", "60")
  ) +
  scale_fill_manual(values = pxp_colors, breaks = pxp_breaks, labels = pxp_labels) +
  labs(x = "\nParticipant", y = "Model Probabilities (PXP)\n", fill = "Model")

plot_pxp
save_plot(plot_pxp, here("figures", "pxp_probs.pdf"), theme4a, 24, 12)

# ── AIC bar plot with error bars ───────────────────────────────────────────────
aic_breaks <- c(
  "aic_1lr_skip",
  "aic_2lr_skip",
  "aic_2lr_confirm",
  "aic_2lr_bias",
  "aic_2lr_skip_3q",
  "aic_2lr_bias_3q",
  "aic_bayes_1prior_skip",
  "aic_bayes_1prior",
  "aic_bayes_3prior_skip",
  "aic_bayes_3prior"
)

aic_labels <- c(
  "aic_1lr_skip"          = "1-LR",
  "aic_2lr_skip"          = "2-LR",
  "aic_2lr_confirm"       = "2-LR\n(confirm)",
  "aic_2lr_bias"          = "2-LR\n(bias)",
  "aic_2lr_skip_3q"       = "2-LR\n(init)",
  "aic_2lr_bias_3q"       = "2-LR\n(bias+init)",
  "aic_bayes_1prior_skip" = "1-prior\nBayes (skip)",
  "aic_bayes_1prior"      = "1-prior\nBayes",
  "aic_bayes_3prior_skip" = "3-prior\nBayes (skip)",
  "aic_bayes_3prior"      = "3-prior\nBayes"
)

aic_colors <- c(
  "aic_1lr_skip"          = "#9D2E06",
  "aic_2lr_skip"          = "#ED8D6B",
  "aic_2lr_confirm"       = "#F27D52",
  "aic_2lr_bias"          = "#FC723F",
  "aic_2lr_skip_3q"       = "#E64105",
  "aic_2lr_bias_3q"       = "#FCC7B3",
  "aic_bayes_1prior_skip" = "#67ABF0",
  "aic_bayes_1prior"      = "#BAD6F3",
  "aic_bayes_3prior_skip" = "#2281E0",
  "aic_bayes_3prior"      = "#0E569E"
)

df_long_aic <- model_df[!duplicated(model_df$subject), ] %>%
  tidyr::pivot_longer(cols       = starts_with("aic_"),
                      names_to   = "model",
                      values_to  = "aic") %>%
  filter(model %in% aic_breaks)

mean_aic <- df_long_aic %>%
  group_by(model) %>%
  summarise(
    mean_aic = mean(aic, na.rm = TRUE),
    se_aic   = sem(aic),
    ci_aic   = qt(0.975, n() - 1) * sem(aic),
    .groups  = "drop"
  ) %>%
  mutate(model = factor(model, levels = aic_breaks))

plot_aic <- ggplot(mean_aic, aes(x = model, y = mean_aic, fill = model)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  geom_errorbar(
    aes(ymin = mean_aic - se_aic, ymax = mean_aic + se_aic),  # SE bars; swap for ci_aic for 95% CI
    width = 0.3, linewidth = 0.8, colour = "gray30"
  ) +
  geom_text(aes(label = sprintf("%.2f", mean_aic),
                y = mean_aic + se_aic + 0.4),
            vjust = -0.6, size = 10, fontface = "bold") +
  scale_fill_manual(values = aic_colors, breaks = aic_breaks, labels = aic_labels) +
  scale_x_discrete(breaks = aic_breaks, labels = aic_labels) +
  coord_cartesian(ylim = c(70, 100)) +
  labs(x = "\nModel", y = "Mean AIC\n")

theme4c <- theme4a + theme(axis.text.x = element_text(size = 18))

plot_aic
save_plot(plot_aic, here("figures", "aic_means.pdf"), theme4c, 16, 8)

# ── Combined manuscript figure 6 ──────────────────────────────────────────────
library(patchwork)

fig6 <- (plot_aic + theme4a + theme(axis.text.x  = element_blank(),
                                    axis.title.x = element_blank())) /
        (plot_pxp + theme4a) +
  plot_layout(heights = c(1, 1.2), guides = "collect") &
  theme(legend.position = "right")

ggsave(here("figures", "fig6_model_comparison.pdf"),
       fig6, width = 20, height = 16, dpi = 300)
