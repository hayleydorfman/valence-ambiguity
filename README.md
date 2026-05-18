[readMe_github.md](https://github.com/user-attachments/files/27956111/readMe_github.md)
# valence-ambiguity
Data and analysis, task, and model code for Dorfman &amp; Bhui, 2026

## Citations

If you use any of this data, code, or task, please cite Dorfman & Bhui, 2026 and the mfit toolbox:

Dorfman, H.M. & Bhui, R. (2026). Ambiguity and confirmatory reward learning. *Cognition*.

Gershman, S. J. (2016). Empirical priors for reinforcement learning models. *Journal of Mathematical Psychology*, 71, 1-6.

---

## I. Model Code

Computational model code for Dorfman & Bhui, 2026

### Requirements

- MATLAB R2019b or later
- [mfit toolbox](https://github.com/sjgershm/mfit)
  - Required functions: `mfit_optimize`, `mfit_bms_aic` (not part of the original mfit package, but included here)
  - Add the mfit folder to your MATLAB path before running: `addpath(genpath('/path/to/mfit'))`

### Script overview

| File | Purpose |
|------|---------|
| `run_fit_models.m` | Fits all models and saves results to .mat files |
| `summarise_model_fit.m` | Prints model comparison table and saves an AIC bar plot |
| `save_csv.m` | Exports trial-level model output to per-subject CSVs |
| `fit_models.m` | Defines parameter bounds and calls mfit; called by `run_fit_models.m` |
| `load_data.m` | Reads the behavioral CSV into a per-subject struct |
| `lik_unambigcounter_*.m` | Likelihood functions for Experiment 1 (10 models) |
| `lik_ambigcounter_*.m` | Likelihood functions for Experiment 2 (9 models) |

### Data files

The input CSV (`df_behav_exp1.csv`) must be in the same folder as the scripts, or on the MATLAB path. It must contain these columns (all numeric):

| Column | Description |
|--------|-------------|
| `subj_num` | Participant index (integer) |
| `subj_choice` | Chosen arm: 1 = left, 2 = right |
| `feedback` | Reward shown on chosen arm |
| `feedback_left` | Reward on left arm |
| `feedback_right` | Reward on right arm |
| `condition_num` | Block condition: 1 = poor, 2 = rich, 3 = neutral |
| `ambiguity` | 1 if chosen outcome is ambiguous, 0 otherwise |
| `block` | Block index |
| `guess_num` | Subject belief report: 1 = gold, 0 = rocks |
| `better_choice` | Ground-truth better option |
| `sd` | Outcome noise SD for that trial |
| `choice_accuracy` | Whether the subject chose the better option |
| `guess_accuracy` | Whether the subject's belief was correct |

### Step 1 — Fit the models

Open `run_fit_models.m` and set the experiment number at the top:

```matlab
EXPERIMENT = 1;   % 1 = main experiment, 2 = supplemental
```

Then run the script. It calls `fit_models(EXPERIMENT)`, which loads the data and fits all models using mfit. Two .mat files are saved with a timestamp:

- `model_output_exp1_YYYYMMDD_HHMMSS.mat` — contains `results` and `bms_results`
- `data_exp1_YYYYMMDD_HHMMSS.mat` — contains the `data` struct (needed by `save_csv.m`)

**Expected runtime:** several minutes to over an hour depending on hardware and sample size, because `mfit_optimize` runs a multi-start optimisation per subject per model.

Alternatively, you can call the functions directly from the command window:

```matlab
data = load_data('df_behav_exp1.csv');
[results, bms_results] = fit_models(1);
```

#### Model fitting (Experiment 1)

Ten models are fit in order. The index corresponds to the position in `results`.

| Index | Model | Parameters |
|-------|-------|------------|
| 1 | `1LR_skip` | inverse temperature, learning rate, stickiness |
| 2 | `bayesian_1prior_skip` | inverse temperature, stickiness, prior SD, prior mean |
| 3 | `bayesian_1prior` | inverse temperature, stickiness, prior SD, prior mean |
| 4 | `bayesian_3prior_skip` | inverse temperature, stickiness, prior SD, prior mean x3 |
| 5 | `bayesian_3prior` | inverse temperature, stickiness, prior SD, prior mean x3 |
| 6 | `2LR_skip` | inverse temperature, lr\_pos, lr\_neg, stickiness |
| 7 | `2LR_bias` | inverse temperature, lr\_pos, lr\_neg, stickiness, bias |
| 8 | `2LR_skip_3Q` | inverse temperature, lr\_pos, lr\_neg, stickiness, q\_poor, q\_rich, q\_neutral |
| 9 | `2LR_bias_3Q` | inverse temperature, lr\_pos, lr\_neg, stickiness, bias, q\_poor, q\_rich, q\_neutral |
| 10 | `confirm_2lr` | inverse temperature, lr\_confirm, lr\_disconfirm, stickiness |

Bayesian model selection (BMS via AIC) runs automatically after all models are fit, producing protected exceedance probabilities (PXP) stored in `bms_results`.

### Step 2 — Summarize results

Open `summarise_model_fit.m` and update the settings at the top to point to your .mat file:

```matlab
MAT_FILE   = 'model_output_exp1_YYYYMMDD_HHMMSS.mat';
EXPERIMENT = 1;
```

Run the script. It prints to the console:

- Per-subject AIC winners
- Group-level mean AIC, summed AIC, and delta AIC relative to the best model
- PXP and expected model frequency from BMS
- Agreement between individual AIC and PXP assignments
- A clean copy-paste table for use in a manuscript

It also saves a PDF bar chart of mean AIC values. The default output filename is `model_comparison_aic.pdf`; change `PDF_FILE` at the top of the script to rename it.

### Step 3 — Export trial-level output

Load the .mat files saved in Step 1, then run `save_csv.m`:

```matlab
load('model_output_exp1_YYYYMMDD_HHMMSS.mat')   % loads results, bms_results
load('data_exp1_YYYYMMDD_HHMMSS.mat')            % loads data
```

Set the output folder at the top of `save_csv.m`:

```matlab
OUT_DIR = './model_output_csvs';
```

The script writes one CSV per subject to that folder (`1_modeloutput.csv`, `2_modeloutput.csv`, ...). Each CSV has a header row and one row per trial.

These CSVs are the input to the R plotting scripts (`plot_learning_curves_beliefs.R`, `plot_behave_beliefs.R`, `plot_PXP.R`). Concatenate the per-subject files and add the header before reading into R.

---

## II. Analysis Code

R analysis and plotting code for Dorfman & Bhui, 2026

### Requirements

**R packages**

Install all required packages before running any script:

```r
install.packages(c(
  "here", "dplyr", "tidyr", "ggplot2", "patchwork",
  "plyr", "reshape2", "rlang", "RColorBrewer",
  "egg", "gridExtra", "grid", "brms"
))
```

> **Note on `brms`:** The `brms` package requires a working Stan installation. See [mc-stan.org/users/interfaces/rstan](https://mc-stan.org/users/interfaces/rstan) for setup instructions. `brms` is only needed for `bayesian_regressions.R`; all other scripts run without it.

### Data files

| File | Description |
|------|-------------|
| `df_behav_exp1.csv` | Trial-level behavioral data, Exp 1 |
| `df_behav_exp2.csv` | Trial-level behavioral data, Exp 2 |
| `model_df_exp1.csv` | Pre-processed model output: trial-level model predictions, PXP values, and AIC/BIC scores for all candidate models, Exp 1 |

### Script overview

#### Utility scripts (sourced automatically)

**`plot_themes.R`**

Defines all ggplot2 theme objects used across the plotting scripts (`theme4`, `theme4a`, `theme5`, etc.). Source this at the top of any plotting script:

```r
source(here("plot_themes.R"))
```

**`save_plot.R`**

A thin wrapper around `ggsave()` that applies a theme when saving:

```r
save_plot(plot_obj, here("figures", "output.pdf"), theme4a, width = 24, height = 12)
```

**`SEM.R`**

Three helper functions for grouped summary statistics:

- `summarySE()` — mean, SD, SE, and CI by group
- `normDataWithin()` — within-subject normalisation (used internally)
- `summarySEwithin()` — within-subject corrected SE/CI following Morey (2008)

#### Analysis and plotting scripts

**`plot_PXP.R`**

Plots model comparison results. Produces:

- `figures/pxp_probs.pdf` — stacked bar chart of protected exceedance probabilities (PXP) per participant
- `figures/aic_means.pdf` — mean AIC with standard error bars across models
- `figures/fig6_model_comparison.pdf` — combined manuscript Figure 6

**Data needed:** `model_df_exp1.csv`

---

**`plot_learning_curves_beliefs.R`**

Plots choice accuracy learning curves and belief trajectories over trials, comparing participants to model predictions. Produces:

- `figures/learning_curves.pdf` — choice accuracy by trial and condition (data vs model), faceted by condition
- `figures/beliefs_5panel_p16.pdf` — 5-panel figure comparing subjective beliefs to three model families (1-prior Bayes, 3-prior Bayes, RL), for all participants and winning-model subsets

**Data needed:** `df_behav_exp1.csv`, `model_df_exp1.csv`

---

**`plot_behave_beliefs.R`**

Plots subjective beliefs against model predictions and objective gold prevalence. Produces:

- `figures/fig7_beliefs_2x2.pdf` — 2×2 grid comparing data vs model beliefs for 1-prior and 3-prior Bayesian models
- `figures/beliefs_truth.pdf` — beliefs vs objective gold prevalence over trials
- `figures/fig_belief_bar_truth.pdf` — combined bar chart and trajectory plot

**Data needed:** `df_behav_exp1.csv`, `model_df_exp1.csv`

---

**`bayesian_regressions.R`**

Three Bayesian logistic regressions using `brms`:

- **Stay/switch ~ belief + feedback history** — tests whether belief in gold on the prior ambiguous trial predicts staying with the same choice
- **Stay/switch ~ belief × magnitude** — adds an interaction with the magnitude of feedback shown
- **Order effects** — tests whether the condition of the previous block influences beliefs in the current block

**Data needed:** `df_behav_exp1.csv`, `model_df_exp1.csv`

Fitting these models can take minutes to hours depending on your machine and Stan configuration. Results are printed to the console; add `saveRDS()` calls if you want to cache fitted models.

### Recommended run order

For a complete reproduction of the paper figures, run scripts in this order:

1. `plot_learning_curves_beliefs.R`
2. `plot_behave_beliefs.R`
3. `plot_PXP.R`
4. `bayesian_regressions.R`

---

## III. Behavioral Task Code

Task code for Dorfman & Bhui, 2026

### Tasks

The behavioral tasks used for both experiments in the paper are provided here. They were created using Josh deLeeuw's [jsPsych toolbox](http://www.jspsych.org/).

Both tasks will not run "out of the box" because they require communication with a PHP server. You can achieve this by running them on your own domain, or by using a tool like XAMPP to run the PHP server locally. You could also use an easy-to-use experiment hosting service — a recommended option is [Cognition](https://www.cognition.run/).

Please also note that slight modifications may need to be made to the existing code to either run the task locally or on a hosting service. For example, the consent and data save functions will need to be commented out in order to run the task locally (if you do not have PHP capabilities). The 'img' folder will need to be moved to the same folder you are running the html file from. Images are the same for both experiments.

For more information on running online jsPsych experiments, please see the extensive documentation available on the jsPsych website, Github discussion forum, and particularly [here](https://www.jspsych.org/overview/running-experiments/).

---

## Questions

Please contact Hayley Dorfman (hdorfman@g.harvard.edu)
