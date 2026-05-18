%% save_csv.m
% Save per-subject model output to individual CSV files, one per subject.
%
% INSTRUCTIONS:
%   1. Load the workspace saved by run_fit_models.m:
%        load('model_output_exp1_YYYYMMDD_HHMMSS.mat')   % results, bms_results
%        load('data_exp1_YYYYMMDD_HHMMSS.mat')           % data
%   2. Set OUT_DIR to the folder where you want the CSVs written.
%      It will be created automatically if it does not exist.
%   3. Run this script.
%
% OUTPUT:
%   One CSV per subject: <OUT_DIR>/<subject_index>_modeloutput.csv
%   Each CSV has a header row followed by one row per trial.

%% ---- USER SETTINGS --------------------------------------------------------

OUT_DIR = fullfile('.', 'model_output_csvs');   % output folder

%% ---- SETUP ----------------------------------------------------------------

if ~exist(OUT_DIR, 'dir')
    mkdir(OUT_DIR);
    fprintf('Created output directory: %s\n', OUT_DIR);
end

S = length(data);   % number of subjects

%% ---- COLUMN HEADERS -------------------------------------------------------
% These must match the order of columns in the temp matrix below.

col_headers = { ...
    'subject', 'condition', 'feedback_shown', 'feedback_left', 'feedback_right', ...
    'better_choice', 'block', 'choice', 'ambig', ...
    'p_belief_1lr_skip', 'p_belief_bayes_1prior', 'p_belief_bayes_3prior', ...
    'prior_mean_adv', 'prior_mean_ben', 'prior_mean_rand', 'prior_mean_1prior', ...
    'lr_1lr_skip', 'lr_safe_bayes_1prior', 'lr_risky_bayes_1prior', ...
    'lr_safe_bayes_3prior', 'lr_risky_bayes_3prior', ...
    'pxp_1lr_skip', 'pxp_bayes_1prior_skip', 'pxp_bayes_1prior', ...
    'pxp_bayes_3prior_skip', 'pxp_bayes_3prior', ...
    'aic_1lr_skip', 'bic_1lr_skip', 'aic_bayes_1prior', 'bic_bayes_1prior', ...
    'aic_bayes_3prior', 'bic_bayes_3prior', ...
    'v_left_1prior', 'v_right_1prior', 'v_left_3prior', 'v_right_3prior', ...
    'pxp_2lr_skip', 'pxp_2lr_bias', 'pxp_2lr_skip_3q', 'pxp_2lr_bias_3q', ...
    'aic_bayes_1prior_skip', 'bic_bayes_1prior_skip', ...
    'aic_bayes_3prior_skip', 'bic_bayes_3prior_skip', ...
    'aic_2lr_skip', 'bic_2lr_skip', 'aic_2lr_bias', 'bic_2lr_bias', ...
    'aic_2lr_skip_3q', 'bic_2lr_skip_3q', 'aic_2lr_bias_3q', 'bic_2lr_bias_3q', ...
    'choice_prob_left', 'choice_prob_right', ...
    'aic_2lr_confirm', 'bic_2lr_confirm', 'pxp_2lr_confirm', 'p_belief_2lr_bias_3Q'};

header_str = strjoin(col_headers, ',');

%% ---- WRITE PER-SUBJECT CSVs -----------------------------------------------

for i = 1:S
    N = data(i).N;   % trials for this subject (do not hardcode)

    filename = fullfile(OUT_DIR, sprintf('%d_modeloutput.csv', i));

    % ---- pull trial-level latents ------------------------------------------
    choice_prob_left  = results(5).latents(i).choiceprob(:, 1);
    choice_prob_right = results(5).latents(i).choiceprob(:, 2);
    better_choice     = data(i).better_choice;
    condition         = data(i).cond;
    feedback_shown    = data(i).r_shown;
    feedback_left     = data(i).r(:, 1);
    feedback_right    = data(i).r(:, 2);
    subject           = repmat(data(i).sub, N, 1);
    choice            = data(i).c;
    block             = data(i).block;
    ambig             = data(i).ambig;

    p_belief_1lr_skip    = results(1).latents(i).p_belief;
    p_belief_bayes_1prior= results(3).latents(i).p_belief;
    p_belief_bayes_3prior= results(5).latents(i).p_belief;

    prior_mean_adv  = repmat(results(5).x(i, 4), N, 1);
    prior_mean_ben  = repmat(results(5).x(i, 5), N, 1);
    prior_mean_rand = repmat(results(5).x(i, 6), N, 1);
    prior_mean_1prior = repmat(results(3).x(i, 4), N, 1);

    lr_1lr_skip            = results(1).latents(i).lr;
    lr_safe_bayes_1prior   = results(3).latents(i).lr(:, 1);
    lr_risky_bayes_1prior  = results(3).latents(i).lr(:, 2);
    lr_safe_bayes_3prior   = results(5).latents(i).lr(:, 1);
    lr_risky_bayes_3prior  = results(5).latents(i).lr(:, 2);

    % ---- scalar results expanded to N rows ---------------------------------
    pxp_1lr_skip        = repmat(bms_results.g(i, 1),  N, 1);
    pxp_bayes_1prior_skip= repmat(bms_results.g(i, 2), N, 1);
    pxp_bayes_1prior    = repmat(bms_results.g(i, 3),  N, 1);
    pxp_bayes_3prior_skip= repmat(bms_results.g(i, 4), N, 1);
    pxp_bayes_3prior    = repmat(bms_results.g(i, 5),  N, 1);
    pxp_2lr_skip        = repmat(bms_results.g(i, 6),  N, 1);
    pxp_2lr_bias        = repmat(bms_results.g(i, 7),  N, 1);
    pxp_2lr_skip_3q     = repmat(bms_results.g(i, 8),  N, 1);
    pxp_2lr_bias_3q     = repmat(bms_results.g(i, 9),  N, 1);
    pxp_2lr_confirm     = repmat(bms_results.g(i, 10), N, 1);

    aic_1lr_skip         = repmat(results(1).aic(i),  N, 1);
    bic_1lr_skip         = repmat(results(1).bic(i),  N, 1);
    aic_bayes_1prior     = repmat(results(3).aic(i),  N, 1);
    bic_bayes_1prior     = repmat(results(3).bic(i),  N, 1);
    aic_bayes_3prior     = repmat(results(5).aic(i),  N, 1);
    bic_bayes_3prior     = repmat(results(5).bic(i),  N, 1);
    aic_bayes_1prior_skip= repmat(results(2).aic(i),  N, 1);
    bic_bayes_1prior_skip= repmat(results(2).bic(i),  N, 1);
    aic_bayes_3prior_skip= repmat(results(4).aic(i),  N, 1);
    bic_bayes_3prior_skip= repmat(results(4).bic(i),  N, 1);
    aic_2lr_skip         = repmat(results(6).aic(i),  N, 1);
    bic_2lr_skip         = repmat(results(6).bic(i),  N, 1);
    aic_2lr_bias         = repmat(results(7).aic(i),  N, 1);
    bic_2lr_bias         = repmat(results(7).bic(i),  N, 1);
    aic_2lr_skip_3q      = repmat(results(8).aic(i),  N, 1);
    bic_2lr_skip_3q      = repmat(results(8).bic(i),  N, 1);
    aic_2lr_bias_3q      = repmat(results(9).aic(i),  N, 1);
    bic_2lr_bias_3q      = repmat(results(9).bic(i),  N, 1);
    aic_2lr_confirm      = repmat(results(10).aic(i), N, 1);
    bic_2lr_confirm      = repmat(results(10).bic(i), N, 1);

    v_left_1prior  = results(3).latents(i).v(:, 1);
    v_right_1prior = results(3).latents(i).v(:, 2);
    v_left_3prior  = results(5).latents(i).v(:, 1);
    v_right_3prior = results(5).latents(i).v(:, 2);

    p_belief_2lr_bias_3Q = results(9).latents(i).p_belief;

    % ---- assemble matrix ---------------------------------------------------
    temp = [subject, condition, feedback_shown, feedback_left, feedback_right, ...
        better_choice, block, choice, ambig, ...
        p_belief_1lr_skip, p_belief_bayes_1prior, p_belief_bayes_3prior, ...
        prior_mean_adv, prior_mean_ben, prior_mean_rand, prior_mean_1prior, ...
        lr_1lr_skip, lr_safe_bayes_1prior, lr_risky_bayes_1prior, ...
        lr_safe_bayes_3prior, lr_risky_bayes_3prior, ...
        pxp_1lr_skip, pxp_bayes_1prior_skip, pxp_bayes_1prior, ...
        pxp_bayes_3prior_skip, pxp_bayes_3prior, ...
        aic_1lr_skip, bic_1lr_skip, aic_bayes_1prior, bic_bayes_1prior, ...
        aic_bayes_3prior, bic_bayes_3prior, ...
        v_left_1prior, v_right_1prior, v_left_3prior, v_right_3prior, ...
        pxp_2lr_skip, pxp_2lr_bias, pxp_2lr_skip_3q, pxp_2lr_bias_3q, ...
        aic_bayes_1prior_skip, bic_bayes_1prior_skip, ...
        aic_bayes_3prior_skip, bic_bayes_3prior_skip, ...
        aic_2lr_skip, bic_2lr_skip, aic_2lr_bias, bic_2lr_bias, ...
        aic_2lr_skip_3q, bic_2lr_skip_3q, aic_2lr_bias_3q, bic_2lr_bias_3q, ...
        choice_prob_left, choice_prob_right, ...
        aic_2lr_confirm, bic_2lr_confirm, pxp_2lr_confirm, p_belief_2lr_bias_3Q];

    % ---- write header + data -----------------------------------------------
    fid = fopen(filename, 'w');
    fprintf(fid, '%s\n', header_str);
    fclose(fid);
    writematrix(temp, filename, 'WriteMode', 'append');

    if mod(i, 10) == 0 || i == S
        fprintf('Saved subject %d / %d\n', i, S);
    end
end

fprintf('\nAll subject CSVs written to: %s\n', OUT_DIR);
