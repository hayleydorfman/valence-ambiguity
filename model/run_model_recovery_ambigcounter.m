% run_model_recovery_ambigcounter.m
% Model recovery using AIC/BIC (and optional Laplace LME for BMS via mfit_bms_aic or mfit_bms).
% Models:
% 1.  lik_ambigcounter_1LR_skip
% 2.  lik_ambigcounter_bayesian_1prior_skip
% 3.  lik_ambigcounter_bayesian_1prior
% 4.  lik_ambigcounter_bayesian_3prior_skip
% 5.  lik_ambigcounter_bayesian_3prior
% 6.  lik_ambigcounter_2LR_skip
% 7.  lik_ambigcounter_2LR_bias
% 8.  lik_ambigcounter_2LR_skip_3Q
% 9.  lik_ambigcounter_2LR_bias_3Q

clear; clc; rng(17);

%% ---------------- USER SETTINGS ----------------
tpb              = 10;            % trials per block (fixed)
n_blocks         = 6;             % 6 blocks
n_synth_per_gen  = 100;           % datasets per generator
p_ambig          = 0.50;          % chosen outcome ambiguous with prob 0.5
mu_good          = 10;            % mean of better arm
mu_bad           = -10;           % mean of worse arm
obs_sd           = 10;            % SD of Gaussian outcomes
restarts         = 10;            % MAP random starts
use_parallel     = true;         % set true for Parallel Toolbox

% >>> Per-dataset model selection criterion: 'AIC' or 'BIC'
criterion        = 'AIC';

% >>> Choose which group-BMS function to use:
%     'AIC'     -> mfit_bms_aic(results_bms, 1)     (force AIC)
%     'LAPLACE' -> mfit_bms_aic(results_bms, 0)     (Laplace with AIC fallback)
%     'BIC'     -> mfit_bms(results_bms, 1)         (BIC)
bms_method       = 'AIC';

% IMPORTANT: choose which fit_models.m experiment's param specs to mirror.
EXPERIMENT_FOR_SPECS = 2;

% Condition coding: 1=poor, 2=rich, 3=neutral; appears twice (permute per dataset)
conds_all = [1 2 3 1 2 3];

labels = { ...
  '1LR-skip', ...
  'Bayes-1prior-skip', ...
  'Bayes-1prior', ...
  'Bayes-3prior-skip', ...
  'Bayes-3prior', ...
  '2LR-skip', ...
  '2LR-bias', ...
  '2LR-skip-3Q', ...
  '2LR-bias-3Q'};
Kmods = numel(labels);

%% ---------------- DRAW GROUND-TRUTH PARAMETERS ----------------
Theta1  = draw_params_from_specs('lik_ambigcounter_1LR_skip',             n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta2  = draw_params_from_specs('lik_ambigcounter_bayesian_1prior_skip', n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta3  = draw_params_from_specs('lik_ambigcounter_bayesian_1prior',      n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta4  = draw_params_from_specs('lik_ambigcounter_bayesian_3prior_skip', n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta5  = draw_params_from_specs('lik_ambigcounter_bayesian_3prior',      n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta6  = draw_params_from_specs('lik_ambigcounter_2LR_skip',             n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta7  = draw_params_from_specs('lik_ambigcounter_2LR_bias',             n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta8  = draw_params_from_specs('lik_ambigcounter_2LR_skip_3Q',          n_synth_per_gen, EXPERIMENT_FOR_SPECS);
Theta9  = draw_params_from_specs('lik_ambigcounter_2LR_bias_3Q',          n_synth_per_gen, EXPERIMENT_FOR_SPECS);

ThetaCell = {Theta1,Theta2,Theta3,Theta4,Theta5,Theta6,Theta7,Theta8,Theta9};

%% ---------------- SIMULATE FROM EACH GENERATOR ----------------
D = cell(Kmods,1);

if use_parallel
    parfor i = 1:n_synth_per_gen
        cond_per_block_i = conds_all(randperm(6));
        D1{i}  = sim_1LR_skip(        Theta1(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D2{i}  = sim_B1_skip(         Theta2(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D3{i}  = sim_B1(              Theta3(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D4{i}  = sim_B3_skip(         Theta4(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D5{i}  = sim_B3(              Theta5(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D6{i}  = sim_2LR_skip(        Theta6(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D7{i}  = sim_2LR_bias(        Theta7(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D8{i}  = sim_2LR_skip_3Q(     Theta8(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D9{i}  = sim_2LR_bias_3Q(     Theta9(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
    end
    D{1}=D1; D{2}=D2; D{3}=D3; D{4}=D4; D{5}=D5;
    D{6}=D6; D{7}=D7; D{8}=D8; D{9}=D9;
else
    for i = 1:n_synth_per_gen
        cond_per_block_i = conds_all(randperm(6));
        D{1}{i}  = sim_1LR_skip(        Theta1(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{2}{i}  = sim_B1_skip(         Theta2(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{3}{i}  = sim_B1(              Theta3(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{4}{i}  = sim_B3_skip(         Theta4(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{5}{i}  = sim_B3(              Theta5(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{6}{i}  = sim_2LR_skip(        Theta6(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{7}{i}  = sim_2LR_bias(        Theta7(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{8}{i}  = sim_2LR_skip_3Q(     Theta8(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
        D{9}{i}  = sim_2LR_bias_3Q(     Theta9(i,:),  tpb, n_blocks, cond_per_block_i, p_ambig, mu_good, mu_bad, obs_sd);
    end
end

%% ---------------- FIT ALL 9 MODELS TO EVERY DATASET ----------------
acc  = nan(1,Kmods);
conf = zeros(Kmods,Kmods);

AllRes     = cell(1,Kmods);
bms_all    = cell(1,Kmods);
chosen_all = cell(1,Kmods);

paramSpecs = get_all_param_specs(EXPERIMENT_FOR_SPECS);

for gen = 1:Kmods
    chosen = nan(n_synth_per_gen,1);

    Res = cell(1,Kmods);
    for m = 1:Kmods
        K = numel(paramSpecs{m});
        Res{m} = repmat(struct('bic',[],'aic',[],'loglik',[],'logpost',[], ...
                               'H',[],'K',K,'x',[],'param_names',{{}}), ...
                        n_synth_per_gen, 1);
    end

    if use_parallel
        Res_all = cell(n_synth_per_gen, 1);
        parfor i = 1:n_synth_per_gen
            [scores, Res_i] = fit_all_10(D{gen}{i}, restarts, criterion, paramSpecs, i);
            Res_all{i} = Res_i;
            [~, chosen(i)] = max(scores);
        end
        for i = 1:n_synth_per_gen
            for m = 1:Kmods, Res{m}(i) = Res_all{i}{m}; end
        end
    else
        for i = 1:n_synth_per_gen
            [scores, Res_i] = fit_all_10(D{gen}{i}, restarts, criterion, paramSpecs, i);
            for m = 1:Kmods, Res{m}(i) = Res_i{m}; end
            [~, chosen(i)] = max(scores);
        end
    end

    for i = 1:n_synth_per_gen
        conf(gen, chosen(i)) = conf(gen, chosen(i)) + 1;
    end

    % -------- Group BMS --------
    clear results_bms
    for m = 1:Kmods, results_bms(m) = pack_for_bms(Res{m}); end

    switch upper(bms_method)
        case 'AIC',     bms_out = mfit_bms_aic(results_bms, 1);
        case 'LAPLACE', bms_out = mfit_bms_aic(results_bms, 0);
        case 'BIC',     bms_out = mfit_bms(results_bms, 1);
        otherwise,      error('Unknown bms_method: %s', bms_method);
    end

    AllRes{gen}     = Res;
    bms_all{gen}    = bms_out;
    chosen_all{gen} = chosen;

    fprintf('\n=== TRUE generator: %s | tpb=%d ===\n', labels{gen}, tpb);
    disp(array2table(conf, 'VariableNames',labels,'RowNames',labels));
    acc(gen) = conf(gen,gen) / max(1, sum(conf(gen,:)));
    fprintf('Per-gen recovery accuracy: %.1f%%\n', 100*acc(gen));
    fprintf('BMS (group): method=%s | xp = %s,  BOR=%0.3f\n', bms_method, mat2str(bms_out.xp,3), bms_out.bor);
end

%% ---------------- SAVE & PLOT ----------------
outdir = sprintf('results_model_recovery_ambigcounter_%dtpb_%dblocks_%dmodels', tpb, n_blocks, Kmods);
if ~exist(outdir,'dir'), mkdir(outdir); end
ts = datestr(now,'yyyymmdd_HHMMSS');

Tsum = table( ...
    tpb*ones(Kmods,1), (1:Kmods)', 100*acc(:), ...
    'VariableNames', {'trials_per_block','true_generator_index','recovery_accuracy_percent'} ...
);
writetable(Tsum, fullfile(outdir, sprintf('summary_%s.csv', ts)));

save(fullfile(outdir, sprintf('workspace_%s.mat', ts)), ...
     'tpb','n_blocks','n_synth_per_gen','p_ambig','mu_good','mu_bad','obs_sd', ...
     'conf','acc','labels', ...
     'D', ...
     'Theta1','Theta2','Theta3','Theta4','Theta5','Theta6','Theta7','Theta8','Theta9', ...
     'ThetaCell', ...
     'AllRes','bms_all','chosen_all', ...
     'criterion','bms_method');

if exist('results_bms','var')
    save(fullfile(outdir, sprintf('results_bms_last_%s.mat', ts)), 'results_bms');
end

hFig = figure('Name','Model recovery (ambigcounter, 10 models)');
bar(100*acc);
set(gca,'XTick',1:Kmods,'XTickLabel',labels,'XTickLabelRotation',30);
ylabel('Recovery accuracy (%)');
title(sprintf('Model recovery (ambigcounter) | tpb=%d | criterion=%s | BMS=%s', tpb, criterion, bms_method));
grid on;
saveas(hFig, fullfile(outdir, sprintf('model_recovery_bar_%s.png', ts)));
saveas(hFig, fullfile(outdir, sprintf('model_recovery_bar_%s.fig', ts)));

% =========================================================================
% ========================= FIT ALL 9 MODELS ==============================
% =========================================================================
function [scores, Res_i] = fit_all_10(Di, restarts, criterion, paramSpecs, dataset_idx)
    if nargin >= 5 && ~isempty(dataset_idx)
        fprintf('Dataset %d ...\n', dataset_idx);
    end

    like_names = { ...
        'lik_ambigcounter_1LR_skip', ...
        'lik_ambigcounter_bayesian_1prior_skip', ...
        'lik_ambigcounter_bayesian_1prior', ...
        'lik_ambigcounter_bayesian_3prior_skip', ...
        'lik_ambigcounter_bayesian_3prior', ...
        'lik_ambigcounter_2LR_skip', ...
        'lik_ambigcounter_2LR_bias', ...
        'lik_ambigcounter_2LR_skip_3Q', ...
        'lik_ambigcounter_2LR_bias_3Q'};

    like = cellfun(@resolve_fun, like_names, 'UniformOutput', false);

    M = numel(like);
    Res_i  = cell(1,M);
    scores = zeros(1,M);
    for m = 1:M
        R = mfit_optimize(like{m}, paramSpecs{m}, Di, restarts);
        Res_i{m} = struct('bic',R.bic(1), 'aic',R.aic(1), 'loglik',R.loglik(1), ...
                          'logpost',R.logpost(1), 'H',R.H{1}, 'K',numel(paramSpecs{m}), ...
                          'x',R.x(1,:), 'param_names',{get_param_names(paramSpecs{m})});
        switch upper(criterion)
            case 'AIC', scores(m) = -0.5 * Res_i{m}.aic;
            case 'BIC', scores(m) = -0.5 * Res_i{m}.bic;
            otherwise,  error('Unknown criterion: %s', criterion);
        end
    end
end

function Rb = pack_for_bms(ResArray)
    Rb.bic     = vertcat(ResArray.bic);
    Rb.aic     = vertcat(ResArray.aic);
    Rb.logpost = [ResArray.logpost];
    Rb.H       = reshape({ResArray.H}, [], 1);
    Rb.K       = ResArray(1).K;
end

% =========================================================================
% =========================== PARAM SPEC HELPERS ==========================
% =========================================================================
function C = get_all_param_specs(experiment_id)
    names = { ...
      'lik_ambigcounter_1LR_skip', ...
      'lik_ambigcounter_bayesian_1prior_skip', ...
      'lik_ambigcounter_bayesian_1prior', ...
      'lik_ambigcounter_bayesian_3prior_skip', ...
      'lik_ambigcounter_bayesian_3prior', ...
      'lik_ambigcounter_2LR_skip', ...
      'lik_ambigcounter_2LR_bias', ...
      'lik_ambigcounter_2LR_skip_3Q', ...
      'lik_ambigcounter_2LR_bias_3Q'};

    specmap = specs_by_experiment(experiment_id);
    C = cell(1, numel(names));
    for i = 1:numel(names)
        if ~isfield(specmap, names{i})
            error('Experiment %d does not define params for %s', experiment_id, names{i});
        end
        C{i} = specmap.(names{i});
    end
end

function S = specs_by_experiment(exp_id)
    switch exp_id
        case {2}

            S.lik_ambigcounter_1LR_skip = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','lr',        'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','sticky',    'logpdf',@(x) 0,                   'lb',-10,'ub',10)
            ];

            S.lik_ambigcounter_bayesian_1prior_skip = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','sticky',    'logpdf',@(x) 0,                   'lb',-10, 'ub',10)
                struct('name','prior_sd',  'logpdf',@(x) 0,                   'lb',0.1, 'ub',100)
                struct('name','prior_mean','logpdf',@(x) 0,                   'lb',-100,'ub',100)
            ];

            S.lik_ambigcounter_bayesian_1prior = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','sticky',    'logpdf',@(x) 0,                   'lb',-10, 'ub',10)
                struct('name','prior_sd',  'logpdf',@(x) 0,                   'lb',0.1, 'ub',100)
                struct('name','prior_mean','logpdf',@(x) 0,                   'lb',-100,'ub',100)
            ];

            S.lik_ambigcounter_bayesian_3prior_skip = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','sticky',      'logpdf',@(x) 0,                   'lb',-10, 'ub',10)
                struct('name','prior_sd',    'logpdf',@(x) 0,                   'lb',0.1, 'ub',100)
                struct('name','prior_mean1', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
                struct('name','prior_mean2', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
                struct('name','prior_mean3', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
            ];

            S.lik_ambigcounter_bayesian_3prior = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','sticky',      'logpdf',@(x) 0,                   'lb',-10, 'ub',10)
                struct('name','prior_sd',    'logpdf',@(x) 0,                   'lb',0.1, 'ub',100)
                struct('name','prior_mean1', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
                struct('name','prior_mean2', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
                struct('name','prior_mean3', 'logpdf',@(x) 0,                   'lb',-100,'ub',100)
            ];

            S.lik_ambigcounter_2LR_skip = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','lr_pos', 'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','lr_neg', 'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','sticky', 'logpdf',@(x) 0,                   'lb',-10,'ub',10)
            ];

            S.lik_ambigcounter_2LR_bias = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','lr_pos', 'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','lr_neg', 'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','sticky', 'logpdf',@(x) 0,                   'lb',-10,'ub',10)
                struct('name','bias',   'logpdf',@(x) 0,                   'lb',-1, 'ub',1)
            ];

            S.lik_ambigcounter_2LR_skip_3Q = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','lr_pos',   'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','lr_neg',   'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','sticky',   'logpdf',@(x) 0,                   'lb',-10,'ub',10)
                struct('name','q_poor',   'logpdf',@(x) 0,                   'lb',-15,'ub',15)
                struct('name','q_rich',   'logpdf',@(x) 0,                   'lb',-15,'ub',15)
                struct('name','q_neutral','logpdf',@(x) 0,                   'lb',-15,'ub',15)
            ];

            S.lik_ambigcounter_2LR_bias_3Q = [
                struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',0,'ub',20)
                struct('name','lr_pos',   'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','lr_neg',   'logpdf',@(x) 0,                   'lb',0,  'ub',1)
                struct('name','sticky',   'logpdf',@(x) 0,                   'lb',-10,'ub',10)
                struct('name','bias',     'logpdf',@(x) 0,                   'lb',-1, 'ub',1)
                struct('name','q_poor',   'logpdf',@(x) 0,                   'lb',-15,'ub',15)
                struct('name','q_rich',   'logpdf',@(x) 0,                   'lb',-15,'ub',15)
                struct('name','q_neutral','logpdf',@(x) 0,                   'lb',-15,'ub',15)
            ];

        otherwise
            error('Experiment %d not recognized in specs_by_experiment for ambigcounter models.', exp_id);
    end
end

function TH = draw_from_specs(N, param)
    K = numel(param); TH = nan(N,K);
    for k = 1:K
        nm = param(k).name;
        lb = getfielddef(param(k),'lb',-inf);
        ub = getfielddef(param(k),'ub', inf);
        switch nm
            case 'invtemp'
                TH(:,k) = gamrnd(4.82,0.88,[N,1]);
            case {'lr','lr_pos','lr_neg','lr_confirm','lr_disconfirm'}
                TH(:,k) = betarnd(1.1,1.1,[N,1]);
            otherwise
                if isfinite(lb) && isfinite(ub)
                    TH(:,k) = lb + (ub-lb).*rand(N,1);
                else
                    TH(:,k) = randn(N,1);
                end
        end
    end
end

function TH = draw_params_from_specs(model_name, N, experiment_id)
    specmap = specs_by_experiment(experiment_id);
    if ~isfield(specmap, model_name)
        error('Experiment %d does not define params for %s', experiment_id, model_name);
    end
    TH = draw_from_specs(N, specmap.(model_name));
end

function val = getfielddef(s, f, default)
    if isfield(s,f), val = s.(f); else, val = default; end
end

% =========================================================================
% =============================== SIMULATORS ==============================
% =========================================================================
function data = sim_1LR_skip(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); lr=theta(2); sticky=theta(3);
    data = skeleton_and_rollout(@policy_softmax_sticky, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, ...
        @(st,c,r,isAmbig) qupdate_1LR_skip(st,c,r,isAmbig,lr), b, sticky);
end

function data = sim_B1_skip(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); sticky=theta(2); prior_sd=theta(3); prior_mean=theta(4);
    data = skeleton_and_rollout_bayes(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
        b, sticky, prior_sd, prior_mean, 'skip');
end

function data = sim_B1(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); sticky=theta(2); prior_sd=theta(3); prior_mean=theta(4);
    data = skeleton_and_rollout_bayes(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
        b, sticky, prior_sd, prior_mean, 'noskip');
end

function data = sim_B3_skip(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); sticky=theta(2); prior_sd=theta(3); pm=theta(4:6);
    data = skeleton_and_rollout_bayes_3prior(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
        b, sticky, prior_sd, pm, 'skip');
end

function data = sim_B3(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); sticky=theta(2); prior_sd=theta(3); pm=theta(4:6);
    data = skeleton_and_rollout_bayes_3prior(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
        b, sticky, prior_sd, pm, 'noskip');
end

function data = sim_2LR_skip(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); lr_pos=theta(2); lr_neg=theta(3); sticky=theta(4);
    data = skeleton_and_rollout(@policy_softmax_sticky, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, ...
        @(st,c,r,isAmbig) qupdate_2LR_skip(st,c,r,isAmbig,lr_pos,lr_neg), b, sticky);
end

function data = sim_2LR_bias(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); lr_pos=theta(2); lr_neg=theta(3); sticky=theta(4); bias=theta(5);
    bias_as_p = max(0.01, min(0.99, 0.5*(bias+1)));
    belief_fun = @(rvec,c,isAmbig) (~isAmbig .* (0.99*(rvec(c)>0) + 0.01*(rvec(c)<0))) + (isAmbig .* bias_as_p);
    data = skeleton_and_rollout(@policy_softmax_sticky, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, ...
        @(st,c,r,isAmbig) qupdate_2LR_bias(st,c,r,isAmbig,lr_pos,lr_neg,bias), b, sticky, 'default', [], belief_fun);
end

function data = sim_2LR_skip_3Q(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); lr_pos=theta(2); lr_neg=theta(3); sticky=theta(4);
    q_poor=theta(5); q_rich=theta(6); q_neutral=theta(7);
    data = skeleton_and_rollout(@policy_softmax_sticky, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, ...
        @(st,c,r,isAmbig) qupdate_2LR_skip(st,c,r,isAmbig,lr_pos,lr_neg), b, sticky, 'threeQ_params', [q_poor q_rich q_neutral]);
end

function data = sim_2LR_bias_3Q(theta, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd)
    b=theta(1); lr_pos=theta(2); lr_neg=theta(3); sticky=theta(4); bias=theta(5);
    q_poor=theta(6); q_rich=theta(7); q_neutral=theta(8);
    bias_as_p = max(0.01, min(0.99, 0.5*(bias+1)));
    belief_fun = @(rvec,c,isAmbig) (~isAmbig .* (0.99*(rvec(c)>0) + 0.01*(rvec(c)<0))) + (isAmbig .* bias_as_p);
    data = skeleton_and_rollout(@policy_softmax_sticky, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, ...
        @(st,c,r,isAmbig) qupdate_2LR_bias(st,c,r,isAmbig,lr_pos,lr_neg,bias), b, sticky, 'threeQ_params', [q_poor q_rich q_neutral], belief_fun);
end

% =========================================================================
% ========================== ROLLOUT FUNCTIONS ============================
% =========================================================================
function data = skeleton_and_rollout(policy_fun, tpb, n_blocks, cond_per_block, p_ambig, mu_good, mu_bad, obs_sd, upd_fun, b, sticky, mode, q_inits, belief_fun)
    if nargin < 12, mode       = 'default'; end
    if nargin < 13, q_inits    = [];        end
    if nargin < 14, belief_fun = [];        end

    T = tpb*n_blocks;
    [c_all,r_all,block_all,cond_all,ambig_all,sd_all] = task_skeleton(tpb,n_blocks,cond_per_block,p_ambig,obs_sd);
    v=[0 0]; u=[0 0];

    for n = 1:T
        if n==1 || block_all(n) ~= block_all(n-1)
            switch mode
                case 'threeQ_params'
                    if isempty(q_inits), error('q_inits must be provided for threeQ_params'); end
                    ci = cond_all(n);
                    if     ci==1, v0 = q_inits(1);
                    elseif ci==2, v0 = q_inits(2);
                    else          v0 = q_inits(3);
                    end
                    v=[v0 v0]; u=[0 0];
                otherwise
                    v=[0 0]; u=[0 0];
            end
        end
        q  = policy_fun(v,u,b,sticky);
        p1 = softmax2(q); c = 1 + (rand()>p1(1)); u=[0 0]; u(c)=1;
        mu_block = [mu_good mu_bad]; if rand()>0.5, mu_block=fliplr(mu_block); end
        r = mu_block + obs_sd*randn(1,2);
        r_all(n,:) = r; c_all(n) = c;
        st.v=v; st.u=u; st.cond=cond_all(n);
        v = upd_fun(st,c,r,ambig_all(n));
    end

    lat_guess = zeros(T,1);
    for n = 1:T
        if ~isempty(belief_fun)
            p_b = belief_fun(r_all(n,:), c_all(n), ambig_all(n));
        else
            if ambig_all(n), p_b = 0.5;
            else, p_b = 0.99*(r_all(n,c_all(n))>0) + 0.01*(r_all(n,c_all(n))<0);
            end
        end
        lat_guess(n) = rand() < p_b;
    end
    data = pack_data_RL(c_all,r_all,block_all,cond_all,ambig_all,sd_all,lat_guess);
end

% Bayesian rollout: BOTH arms ambiguous on ambiguous trials
function data = skeleton_and_rollout_bayes(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
    b, sticky, prior_sd, prior_mean, skipmode)

    T = tpb*n_blocks;
    [c_all,r_all,block_all,cond_all,ambig_all,sd_all] = task_skeleton(tpb,n_blocks,cond_per_block,p_ambig,obs_sd);
    v = [prior_mean prior_mean]; u=[0 0]; sigma_t=[prior_sd^2 prior_sd^2];
    lat_guess = zeros(T,1);

    for n = 1:T
        if n==1 || block_all(n) ~= block_all(n-1)
            v=[prior_mean prior_mean]; u=[0 0]; sigma_t=[prior_sd^2 prior_sd^2];
        end
        q  = b.*v + sticky.*u;
        p1 = softmax2(q); c = 1+(rand()>p1(1)); u=[0 0]; u(c)=1;
        uc = 3-c;
        mu_block = [mu_good mu_bad]; if rand()>0.5, mu_block=fliplr(mu_block); end
        r = mu_block + obs_sd*randn(1,2);
        noise = [obs_sd^2 obs_sd^2];

        if ~ambig_all(n)
            p_belief = 0.99*(r(c)>0) + 0.01*(r(c)<0);
            r_hat=r; rpe=r_hat-v; lr=sigma_t./(noise+sigma_t);
            v=v+lr.*rpe; sigma_t=(1-lr).*sigma_t;
        else
            % Both arms ambiguous
            r_hat=r; sigma_r_hat=noise;
            p_hat_all=nan(1,2);
            for a=[c uc]
                denom = normpdf(abs(r(a)),v(a),sqrt(noise(a))) + normpdf(-abs(r(a)),v(a),sqrt(noise(a)));
                p_hat_a = normpdf(abs(r(a)),v(a),sqrt(noise(a))) / denom;
                p_hat_a = min(max(p_hat_a,0.01),0.99);
                p_hat_all(a) = p_hat_a;
                r_hat(a) = 2*abs(r(a))*(p_hat_a-0.5);
                sigma_r_hat(a) = noise(a) + 4*abs(r(a))^2*p_hat_a*(1-p_hat_a);
            end
            p_belief = p_hat_all(c);
            rpe=r_hat-v; lr=sigma_t./(sigma_r_hat+sigma_t);
            if strcmp(skipmode,'skip'), lr(c)=0; lr(uc)=0; end
            v=v+lr.*rpe; sigma_t=(1-lr).*sigma_t;
        end

        r_all(n,:)=r; c_all(n)=c;
        lat_guess(n) = rand()<p_belief;
    end
    data = pack_data_RL(c_all,r_all,block_all,cond_all,ambig_all,sd_all,lat_guess);
end

% Bayesian 3-prior rollout: BOTH arms ambiguous on ambiguous trials
function data = skeleton_and_rollout_bayes_3prior(tpb,n_blocks,cond_per_block,p_ambig,mu_good,mu_bad,obs_sd, ...
    b, sticky, prior_sd, pm_vec, skipmode)

    T = tpb*n_blocks;
    [c_all,r_all,block_all,cond_all,ambig_all,sd_all] = task_skeleton(tpb,n_blocks,cond_per_block,p_ambig,obs_sd);
    lat_guess = zeros(T,1);

    for n = 1:T
        if n==1 || block_all(n) ~= block_all(n-1)
            v0 = pm_vec(cond_all(n)); v=[v0 v0]; u=[0 0]; sigma_t=[prior_sd^2 prior_sd^2];
        end
        q  = b.*v + sticky.*u;
        p1 = softmax2(q); c=1+(rand()>p1(1)); u=[0 0]; u(c)=1;
        uc = 3-c;
        mu_block = [mu_good mu_bad]; if rand()>0.5, mu_block=fliplr(mu_block); end
        r = mu_block + obs_sd*randn(1,2);
        noise = [obs_sd^2 obs_sd^2];

        if ~ambig_all(n)
            p_belief = 0.99*(r(c)>0) + 0.01*(r(c)<0);
            r_hat=r; rpe=r_hat-v; lr=sigma_t./(noise+sigma_t);
            v=v+lr.*rpe; sigma_t=(1-lr).*sigma_t;
        else
            r_hat=r; sigma_r_hat=noise;
            p_hat_all=nan(1,2);
            for a=[c uc]
                denom = normpdf(abs(r(a)),v(a),sqrt(noise(a))) + normpdf(-abs(r(a)),v(a),sqrt(noise(a)));
                p_hat_a = normpdf(abs(r(a)),v(a),sqrt(noise(a))) / denom;
                p_hat_a = min(max(p_hat_a,0.01),0.99);
                p_hat_all(a) = p_hat_a;
                r_hat(a) = 2*abs(r(a))*(p_hat_a-0.5);
                sigma_r_hat(a) = noise(a) + 4*abs(r(a))^2*p_hat_a*(1-p_hat_a);
            end
            p_belief = p_hat_all(c);
            rpe=r_hat-v; lr=sigma_t./(sigma_r_hat+sigma_t);
            if strcmp(skipmode,'skip'), lr(c)=0; lr(uc)=0; end
            v=v+lr.*rpe; sigma_t=(1-lr).*sigma_t;
        end

        r_all(n,:)=r; c_all(n)=c;
        lat_guess(n) = rand()<p_belief;
    end
    data = pack_data_RL(c_all,r_all,block_all,cond_all,ambig_all,sd_all,lat_guess);
end

% =========================================================================
% ========================= Q-UPDATE FUNCTIONS ============================
% =========================================================================
function q = policy_softmax_sticky(v,u,b,sticky), q = b.*v + sticky.*u; end

function v = qupdate_1LR_skip(st,c,r,isAmbig,lr)
    v=st.v; rpe=r-v;
    % Both arms: skip update on ambiguous trials
    if ~isAmbig
        v(c)   = v(c)   + lr * rpe(c);
        v(3-c) = v(3-c) + lr * rpe(3-c);
    end
end

function v = qupdate_2LR_skip(st,c,r,isAmbig,lr_pos,lr_neg)
    v=st.v; rpe=r-v;
    % Both arms: skip update on ambiguous trials
    if ~isAmbig
        a_c  = (rpe(c)>0).*lr_pos   + (rpe(c)<0).*lr_neg;
        a_uc = (rpe(3-c)>0).*lr_pos + (rpe(3-c)<0).*lr_neg;
        v(c)   = v(c)   + a_c  * rpe(c);
        v(3-c) = v(3-c) + a_uc * rpe(3-c);
    end
end

function v = qupdate_2LR_bias(st,c,r,isAmbig,lr_pos,lr_neg,bias)
    v=st.v; rpe=r-v; uc=3-c;
    if ~isAmbig
        a_c  = (rpe(c)>0).*lr_pos  + (rpe(c)<0).*lr_neg;
        a_uc = (rpe(uc)>0).*lr_pos + (rpe(uc)<0).*lr_neg;
        v(c)  = v(c)  + a_c  * rpe(c);
        v(uc) = v(uc) + a_uc * rpe(uc);
    else
        % Both arms: bias * magnitude
        v(c)  = v(c)  + lr_pos * bias * abs(r(c));
        v(uc) = v(uc) + lr_pos * bias * abs(r(uc));
    end
end

% =========================================================================
% =============================== TASK CORE ===============================
% =========================================================================
function [c_all,r_all,block_all,cond_all,ambig_all,sd_all] = task_skeleton(tpb,n_blocks,cond_per_block,p_ambig,obs_sd)
    T = tpb*n_blocks;
    c_all=nan(T,1); r_all=nan(T,2); block_all=nan(T,1); cond_all=nan(T,1);
    ambig_all=false(T,1); sd_all=obs_sd*ones(T,1);
    t=0;
    for b_ix=1:n_blocks
        cond=cond_per_block(b_ix);
        idx=(1:tpb)+t;
        block_all(idx)=b_ix; cond_all(idx)=cond;
        ambig_all(idx)=rand(tpb,1)<p_ambig;
        t=t+tpb;
    end
end

function data = pack_data_RL(c_all,r_all,block_all,cond_all,ambig_all,sd_all,lat_guess)
    data.c=c_all(:); data.r=r_all; data.N=numel(c_all);
    data.block=block_all(:); data.cond=cond_all(:);
    data.ambig=ambig_all(:); data.sd=sd_all(:);
    data.latent_guess=lat_guess(:);
    data.better_choice=nan(size(c_all));
end

% =========================================================================
% ============================= OPTIMIZER CORE ============================
% =========================================================================
function results = mfit_optimize(likfun,param,data,nstarts)
    if nargin < 4 || isempty(nstarts), nstarts=5; end
    K=length(param); results.K=K; results.param=param; results.likfun=likfun;
    if ~isfield(param,'lb'), lb=-inf(1,K); else, lb=[param.lb]; end
    if ~isfield(param,'ub'), ub= inf(1,K); else, ub=[param.ub]; end
    options=optimoptions('fmincon','Display','off','Algorithm','interior-point',...
        'MaxFunctionEvaluations',5e4,'OptimalityTolerance',1e-6,'StepTolerance',1e-8);
    warning off all
    best=struct('x',[],'logpost',-Inf,'H',[]);
    for i=1:nstarts
        x0=zeros(1,K);
        for k=1:K, x0(k)=unifrnd(lb(k),ub(k)); end
        f=@(x) -mfit_post(x,param,data,likfun);
        [x,nlogp,~,~,~,~,H]=fmincon(f,x0,[],[],[],[],lb,ub,[],options);
        logp=-nlogp;
        if logp>best.logpost, best.x=x; best.logpost=logp; best.H=H; end
    end
    results.logpost(1)=best.logpost;
    results.loglik(1)=likfun(best.x,data);
    results.x(1,:)=best.x; results.H{1}=best.H;
    results.bic(1,1)=K*log(data.N) - 2*results.loglik(1);
    results.aic(1,1)=K*2           - 2*results.loglik(1);
    try, [~,results.latents(1)]=likfun(results.x(1,:),data); catch, results.latents=[]; end
end

function logpost = mfit_post(x,param,data,likfun)
    lp=0; for k=1:numel(param), lp=lp+param(k).logpdf(x(k)); end
    logpost=likfun(x,data)+lp;
end

% =========================================================================
% ================================ UTILS ==================================
% =========================================================================
function p = softmax2(z)
    z=z-max(z); ez=exp(z); p=ez./sum(ez);
end

function y = logsumexp(x,dim)
    if nargin==1, dim=2; end
    xm=max(x,[],dim); y=xm+log(sum(exp(x-xm),dim));
end

function fh = resolve_fun(name)
    if exist(name,'file')~=2 && exist(name,'builtin')~=5
        error('Likelihood "%s" not found on MATLAB path.', name);
    end
    fh=str2func(name);
end

function names = get_param_names(spec)
    names=arrayfun(@(s) s.name, spec, 'UniformOutput', false);
end
