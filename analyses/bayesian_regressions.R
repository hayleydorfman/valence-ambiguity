# ── Bayesian regressions ───────────────────────────────────────────────────────
# Runs two sets of Bayesian logistic regressions using brms:
#   1. Stay/switch behavior after ambiguous trials
#   2. Order effects: does prior block condition influence current behavior?
#
# Note: brms models can take several minutes to hours to fit depending on your
# machine. Fitted model objects are not saved automatically; add
# saveRDS(model, here("models", "model_name.rds")) calls if you want to cache them.
#
# Requires:
#   data/df_behav_exp1.csv
#   data/model_df_exp1.csv
#   SEM.R (for sem helper, if needed downstream)

library(here)
library(dplyr)
library(brms)

source(here("SEM.R"))

# ── Load behavioral data ───────────────────────────────────────────────────────
df <- read.csv(here("data", "df_behav_exp1.csv"))

# ── Data prep: lags and counterfactual feedback ────────────────────────────────
df <- df %>%
  arrange(subject_id, block, trial_num) %>%
  group_by(subject_id, block) %>%
  mutate(
    prev_ambig   = as.integer(lag(ambiguity) == 1),
    prev_choice  = lag(mine_choice),
    same_as_prev_choice         = as.integer(mine_choice == prev_choice),
    prev_guess_num              = lag(guess_num),
    prev_magnitude              = abs(lag(feedback)),
    magnitude                   = if_else(mine_choice == 1, abs(feedback_right), abs(feedback_left)),
    counterfactual_feedback      = if_else(mine_choice == 1, abs(feedback_left), abs(feedback_right)),
    prev_counterfactual_feedback = if_else(prev_choice == 1, lag(feedback_left), lag(feedback_right)),
    hist_mean_right_excl         = lag(cummean(feedback_right), 2),
    hist_mean_left_excl          = lag(cummean(feedback_left), 2),
    prev_feedback_history        = if_else(prev_choice == 1, hist_mean_right_excl, hist_mean_left_excl),
    prev_counterfactual_feedback_history = if_else(prev_choice == 1, hist_mean_left_excl, hist_mean_right_excl)
  ) %>%
  ungroup()

# ── Regression 1a: stay/switch ~ belief + feedback history (no interaction) ───
modelbmax0 <- brm(
  as.factor(same_as_prev_choice) ~
    prev_guess_num + prev_counterfactual_feedback +
    prev_feedback_history + prev_counterfactual_feedback_history +
    (1 + prev_guess_num + prev_counterfactual_feedback +
       prev_feedback_history + prev_counterfactual_feedback_history | subject_id),
  family = bernoulli(),
  data   = subset(df, prev_ambig == 1),
  cores  = 3,
  seed   = 10
)

drawsmax0 <- as_draws_df(modelbmax0)
mean(drawsmax0["b_prev_guess_num"] > 0)
print(summary(modelbmax0), digits = 3)
round(colMeans(drawsmax0[names(drawsmax0)[grep("b_", names(drawsmax0))]] > 0), 3)

# ── Regression 1b: stay/switch ~ belief x magnitude interaction ────────────────
modelbmax <- brm(
  as.factor(same_as_prev_choice) ~
    prev_guess_num * prev_magnitude + prev_counterfactual_feedback +
    prev_feedback_history + prev_counterfactual_feedback_history +
    (1 + prev_guess_num * prev_magnitude + prev_counterfactual_feedback +
       prev_feedback_history + prev_counterfactual_feedback_history | subject_id),
  family = bernoulli(),
  data   = subset(df, prev_ambig == 1),
  cores  = 3,
  seed   = 10
)

drawsmax <- as_draws_df(modelbmax)
mean(drawsmax["b_prev_guess_num:prev_magnitude"] > 0)
print(summary(modelbmax), digits = 3)
round(colMeans(drawsmax[names(drawsmax)[grep("b_", names(drawsmax))]] > 0), 3)

# ── Regression 2: stay/switch for negative outcomes ~ loss magnitude ───────────
# Uses model output data to get trial-level feedback
model_df <- read.csv(here("data", "model_df_exp1.csv"))

df2 <- model_df %>%
  arrange(subject, block) %>%
  group_by(subject, block) %>%
  mutate(trial_in_block = row_number()) %>%
  ungroup() %>%
  mutate(trial = (block - 1) * 10 + trial_in_block) %>%
  arrange(subject, block, trial_in_block) %>%
  group_by(subject, block) %>%
  mutate(
    next_choice = lead(choice),
    stay        = ifelse(!is.na(next_choice) & next_choice == choice, 1L, 0L)
  ) %>%
  ungroup()

df_neg <- df2 %>% filter(feedback_shown < 0, !is.na(stay))

m_neg_bayes <- brm(
  as.factor(stay) ~ abs(feedback_shown) + (1 | subject),
  data   = df_neg,
  family = bernoulli(),
  cores  = 4,
  seed   = 42
)

draws <- as_draws_df(m_neg_bayes)
mean(draws["b_absfeedback_shown"] < 0)  # expect negative: larger loss → more switching
print(summary(m_neg_bayes), digits = 3)
summary(m_neg_bayes)$fixed

# ── Regression 3: order effects ───────────────────────────────────────────────
# Does the condition of the previous block influence current beliefs?

df <- df %>%
  arrange(subject_id, block, trial_num) %>%
  group_by(subject_id) %>%
  mutate(trial_order = row_number()) %>%
  ungroup()

block_conditions <- df %>%
  distinct(subject_id, block, condition) %>%
  arrange(subject_id, block) %>%
  group_by(subject_id) %>%
  mutate(prev_condition = lag(condition)) %>%
  ungroup()

df <- df %>%
  left_join(block_conditions %>% select(subject_id, block, prev_condition),
            by = c("subject_id", "block"))

m_order <- brm(
  as.factor(guess_num) ~ condition + prev_condition + block + trial_num + (1 | subject_id),
  data   = subset(df, ambiguity == 1),
  family = bernoulli(),
  cores  = 4,
  seed   = 42
)

summary(m_order)
draws_order <- as_draws_df(m_order)
mean(draws_order$b_prev_conditionpoor > 0)
mean(draws_order$b_prev_conditionrich > 0)
