%% run_fit_models.m
% Reproducible wrapper: load data, fit all cognitive models, save outputs.
%
% INSTRUCTIONS:
%   1. Set EXPERIMENT to 1 (main experiment) or 2 (supplemental experiment).
%   2. Confirm the correct CSV filename is listed in fit_models.m for that
%      experiment number.
%   3. Run this script. Results are saved as .mat files with a timestamp.
%
% DEPENDENCIES:
%   fit_models.m, load_data.m, all lik_*.m files, mfit toolbox

clear; clc; close all;

%% ---- USER SETTINGS --------------------------------------------------------

% Which experiment to fit: 1 = main, 2 = supplemental
EXPERIMENT = 2;

% Reproducible random seed
rng(42);

%% ---- FIT MODELS -----------------------------------------------------------
% fit_models loads data internally from the filename defined for EXPERIMENT.
% It returns one results entry per model and Bayesian model selection output.

fprintf('Fitting models for experiment %d...\n', EXPERIMENT);
[results, bms_results] = fit_models(EXPERIMENT);

%% ---- SAVE OUTPUTS ---------------------------------------------------------

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
out_file  = sprintf('model_output_exp%d_%s.mat', EXPERIMENT, timestamp);

save(out_file, 'results', 'bms_results');
fprintf('Results saved to: %s\n', out_file);

% Also load and save the data struct so save_csv.m can use the same workspace
if EXPERIMENT == 1
    data_file = 'df_behav_exp1.csv';
elseif EXPERIMENT == 2
    data_file = 'df_behav_exp2.csv';
end
data = load_data(data_file);
data_out = sprintf('data_exp%d_%s.mat', EXPERIMENT, timestamp);
save(data_out, 'data');
fprintf('Data struct saved to: %s\n', data_out);

fprintf('\nDone. To summarise results, run summarise_model_fit.m\n');
fprintf('Set MAT_FILE = ''%s'' at the top of that script.\n', out_file);
