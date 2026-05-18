# Ambiguity and Confirmatory Reward Learning

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
| `run_model_recovery.m` | Model recovery for Experiment 1 |
| `run_model_recovery_ambigcounter.m` | Model recovery for Experiment 2 |
| `plot_model_recovery.m` | Plots model- and family-level confusion matrices |
| `plot_prior_dispersion_scatter_only.m` | Plots true prior dispersion vs ΔAIC |
| `run_parameter_recovery.m` | Parameter recovery plots and stats for any generator/model pair |

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

#### Models fit (Experiment 1)

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

### Model recovery

Model recovery tests whether the fitting procedure can correctly identify the true generating model when data are simulated from each model in the candidate set.

| File | Purpose |
|------|---------|
| `run_model_recovery.m` | Runs model recovery for Experiment 1 (10 models, `lik_unambigcounter_*`) |
| `run_model_recovery_ambigcounter.m` | Runs model recovery for Experiment 2 (9 models, `lik_ambigcounter_*`) |
| `plot_model_recovery.m` | Loads a saved workspace and plots model-level and family-level confusion matrices |
| `plot_prior_dispersion_scatter_only.m` | Scatter plot of true prior dispersion vs ΔAIC for the 3-prior Bayesian generator |

**How it works:** For each of the 10 (or 9) models, 100 synthetic datasets are simulated using parameters drawn from the same priors used for fitting. All models are then fit to every simulated dataset and the winning model is selected by AIC. The result is a confusion matrix where rows are the true generating model and columns are the winning fitted model. Diagonal entries indicate correct recovery.

**To run model recovery for Experiment 1:**

```matlab
run_model_recovery        % saves workspace_YYYYMMDD_HHMMSS.mat to results_model_recovery_*/
```

**To run model recovery for Experiment 2:**

```matlab
run_model_recovery_ambigcounter   % saves workspace_YYYYMMDD_HHMMSS.mat to results_model_recovery_ambigcounter_*/
```

Key settings at the top of each script:

| Setting | Default | Description |
|---------|---------|-------------|
| `n_synth_per_gen` | 100 | Synthetic datasets per generating model |
| `tpb` | 10 | Trials per block |
| `n_blocks` | 6 | Number of blocks |
| `restarts` | 10 | Random starts for MAP optimization |
| `criterion` | `'AIC'` | Model selection criterion (`'AIC'` or `'BIC'`) |
| `use_parallel` | `true` | Use Parallel Computing Toolbox (recommended) |

**To plot confusion matrices** after running, edit the `MAT_FILE`, `OUTPUT_FILE`, and `OUTPUT_FILE_FAM` paths at the top of `plot_model_recovery.m` and run it. It produces two PDFs: a model-level confusion matrix and a family-level confusion matrix (collapsing across RL, Bayesian, and 2LR model families).

**To plot prior dispersion vs ΔAIC** (for the 3-prior Bayesian generator only):

```matlab
plot_prior_dispersion_scatter_only('path/to/workspace.mat', 'avgabs', 'output.pdf')
```

The `metric` argument controls how prior dispersion is quantified: `'avgabs'` (mean absolute pairwise difference between prior means, default) or `'maxmin'` (max minus min prior mean).

**Expected runtime:** Several hours with `use_parallel = true` (10 restarts × 100 datasets × 10 models). Plan for overnight runs on a standard laptop.

### Parameter recovery

Parameter recovery tests whether the true parameter values used to simulate data can be accurately recovered by the fitting procedure, for each model individually.

**To run parameter recovery** after completing model recovery, load the saved workspace and call `run_parameter_recovery` for each generator:

```matlab
workspace_path = 'results_model_recovery_10tpb_6blocks_10models/workspace_YYYYMMDD_HHMMSS.mat';
exp_name       = 'exp1_param_recovery';

S     = load(workspace_path);
Kmods = numel(S.labels);

for g = 1:Kmods
    run_parameter_recovery(workspace_path, g, g, exp_name);
end
```

For Experiment 2, point to the `ambigcounter` workspace instead:

```matlab
workspace_path = 'results_model_recovery_ambigcounter_10tpb_6blocks_9models/workspace_YYYYMMDD_HHMMSS.mat';
exp_name       = 'exp2_param_recovery';
```

```matlab
run_parameter_recovery(workspace_mat, g, m, outdir, param_names)
```

| Argument | Description |
|----------|-------------|
| `workspace_mat` | Path to the `.mat` file from `run_model_recovery` |
| `g` | Generator index (row of the confusion matrix) |
| `m` | Model index to evaluate (default = `g`, i.e. the matched model) |
| `outdir` | Output directory for plots and CSVs (optional; auto-named if omitted) |
| `param_names` | Cell array of parameter name strings (optional; inferred from workspace if available) |

**Outputs** are saved to the specified output directory:

- `param_recovery_g##_<model>__m##_<model>.png` — scatter plots of true vs recovered values for each parameter, with Pearson r and regression slope annotated
- `param_recovery_g##_<model>__m##_<model>.fig` — same figure as an editable MATLAB .fig file
- `param_recovery_stats_g##_<model>__m##_<model>.csv` — table of Pearson r, slope, intercept, and RMSE per parameter

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

Both tasks will not run "out of the box" because they require communication with a PHP server. You can achieve this by running them on your own domain, or by using a tool like XAMPP to run the PHP server locally. You could also use an easy-to-use experiment hosting service — a recommended option is [Cognition](https://www.cognition.run/). The 'img' folder needs to be included in the same folder you use to run the html file from. Images are the same for both experiments.

Please also note that slight modifications may need to be made to the existing code to either run the task locally or on a hosting service. For example, the consent and data save functions will need to be commented out in order to run the task locally (if you do not have PHP capabilities). For more information on running online jsPsych experiments, please see the extensive documentation available on the jsPsych website, Github discussion forum, and particularly [here](https://www.jspsych.org/overview/running-experiments/).

---

## Questions

Please contact Hayley Dorfman (hdorfman@g.harvard.edu)
