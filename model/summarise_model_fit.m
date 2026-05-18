%% summarise_model_fit.m
% Print a model comparison table and save a mean-AIC bar plot.
%
% INSTRUCTIONS:
%   1. Set MAT_FILE to the .mat file produced by run_fit_models.m.
%   2. Set EXPERIMENT to match the experiment number used when fitting.
%   3. Run this script.

%% ---- USER SETTINGS --------------------------------------------------------

MAT_FILE   = 'model_output_exp1_YYYYMMDD_HHMMSS.mat';  % <-- update this
PDF_FILE   = 'model_comparison_aic.pdf';
EXPERIMENT = 1;   % must match the experiment number used in run_fit_models.m

%% ---- AUTO-FETCH model labels ----------------------------------------------

likfuns      = get_likfuns(EXPERIMENT);
model_labels = regexprep(likfuns, '^lik_[^_]+counter_', '');
M            = length(model_labels);

%% ---- LOAD RESULTS ---------------------------------------------------------

load(MAT_FILE, 'results', 'bms_results');
S = length(results(1).bic);

%% ---- AIC matrix -----------------------------------------------------------

aic_mat = zeros(S, M);
for m = 1:M
    aic_mat(:, m) = results(m).aic(:);
end

%% ---- Individual AIC winners -----------------------------------------------

[~, aic_winner] = min(aic_mat, [], 2);
aic_counts = arrayfun(@(m) sum(aic_winner == m), 1:M);

%% ---- Group-level AIC ------------------------------------------------------

mean_aic    = mean(aic_mat, 1);
aic_sums    = sum(aic_mat, 1);
[~, best_m] = min(aic_sums);
delta_aic   = aic_sums - aic_sums(best_m);

%% ---- BMS results (PXP) ----------------------------------------------------

pxp  = bms_results.pxp;
xp   = bms_results.xp;
expr = bms_results.exp_r;

%% ---- Per-subject PXP assignment -------------------------------------------

fprintf('\n--- Subject counts by individual model responsibility (bms_results.g) ---\n');
if isfield(bms_results, 'g')
    [g_max, pxp_winner] = max(bms_results.g, [], 2);
    pxp_counts = arrayfun(@(m) sum(pxp_winner == m), 1:M);

    fprintf('%-30s  %10s  %10s\n', 'Model', 'N subjects', 'Mean g');
    fprintf('%s\n', repmat('-', 1, 55));
    for m = 1:M
        subj_idx = pxp_winner == m;
        if any(subj_idx)
            mean_g = mean(g_max(subj_idx));
        else
            mean_g = NaN;
        end
        fprintf('%-30s  %10d  %10.3f\n', model_labels{m}, pxp_counts(m), mean_g);
    end
    fprintf('%s\n', repmat('-', 1, 55));
    fprintf('%-30s  %10d\n', 'Total', sum(pxp_counts));

    uncertain = g_max < 0.5;
    fprintf('\nSubjects with no clear winner (max g < 0.5): %d\n', sum(uncertain));

    fprintf('\n--- Agreement between AIC and PXP assignment ---\n');
    agree = sum(aic_winner == pxp_winner);
    fprintf('Subjects where AIC and PXP agree: %d / %d (%.1f%%)\n', ...
        agree, S, 100 * agree / S);

    fprintf('\nCross-tab (rows = AIC winner, cols = PXP winner):\n');
    fprintf('%-25s', ' ');
    for m = 1:M; fprintf('%8s', model_labels{m}(1:min(8, end))); end
    fprintf('\n');
    for ma = 1:M
        fprintf('%-25s', model_labels{ma});
        for mp = 1:M
            fprintf('%8d', sum(aic_winner == ma & pxp_winner == mp));
        end
        fprintf('\n');
    end
else
    fprintf('bms_results.g not available\n');
end

%% ---- Summary table --------------------------------------------------------

fprintf('\n========================================\n');
fprintf(' Experiment %d  |  N = %d\n', EXPERIMENT, S);
fprintf('========================================\n\n');

fprintf('%-30s  %8s  %8s  %10s  %10s  %10s  %10s\n', ...
    'Model', 'AIC wins', 'PXP', 'Mean AIC', 'Sum AIC', 'dAIC', 'exp_r');
fprintf('%s\n', repmat('-', 1, 95));
for m = 1:M
    fprintf('%-30s  %8d  %8.3f  %10.1f  %10.1f  %+10.1f  %10.3f\n', ...
        model_labels{m}, aic_counts(m), pxp(m), ...
        mean_aic(m), aic_sums(m), delta_aic(m), expr(m));
end
fprintf('%s\n', repmat('-', 1, 95));
fprintf('%-30s  %8d\n', 'Total subjects', sum(aic_counts));
fprintf('BOR = %.4f\n', bms_results.bor);

fprintf('\n--- Clean table (copy-paste) ---\n');
fprintf('%-30s  %6s  %10s  %8s\n', 'Model', 'PXP', 'Mean AIC', 'N subj');
fprintf('%s\n', repmat('-', 1, 60));
for m = 1:M
    fprintf('%-30s  %6.3f  %10.1f  %8d\n', ...
        model_labels{m}, pxp(m), mean_aic(m), aic_counts(m));
end

%% ---- Mean AIC bar plot ----------------------------------------------------

cmap       = lines(M);
fig        = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 max(14, M * 1.4) 5.5]);
ax         = axes('Parent', fig);

hBar       = bar(ax, mean_aic, 'FaceColor', 'flat', 'EdgeColor', 'none', 'BarWidth', 0.6);
hBar.CData = cmap;

ax.XTick              = 1:M;
ax.XTickLabel         = model_labels;
ax.FontName           = 'Helvetica';
ax.FontSize           = 13;
ax.Box                = 'off';
ax.TickDir            = 'out';
ax.LineWidth          = 1.2;
ax.XColor             = [0.2 0.2 0.2];
ax.YColor             = [0.2 0.2 0.2];
ax.XTickLabelRotation = 30;
grid(ax, 'on');
ax.GridAlpha = 0.2;
ax.GridColor = [0.5 0.5 0.5];

xlabel(ax, 'Model',    'FontSize', 18, 'FontName', 'Helvetica', 'FontWeight', 'bold');
ylabel(ax, 'Mean AIC', 'FontSize', 18, 'FontName', 'Helvetica', 'FontWeight', 'bold');

y_pad = 2;
ylim(ax, [min(mean_aic) - y_pad, max(mean_aic) + y_pad]);

for m = 1:M
    text(ax, m, mean_aic(m) + 0.3, sprintf('%.1f', mean_aic(m)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 11, 'FontName', 'Helvetica', 'FontWeight', 'bold', ...
        'Color', [0.2 0.2 0.2]);
end

ax.Position = [0.08 0.25 0.88 0.65];
set(fig, 'PaperUnits', 'inches', 'PaperSize', [max(14, M * 1.4) 5.5], ...
    'PaperPosition', [0 0 max(14, M * 1.4) 5.5]);
print(fig, PDF_FILE, '-dpdf', '-painters');
fprintf('\nPlot saved to: %s\n', PDF_FILE);
close(fig);

%% ---- HELPER ---------------------------------------------------------------

function likfuns = get_likfuns(experiment)
% Return the likfuns cell array for a given experiment number,
% matching the definitions in fit_models.m.
    if experiment == 1
        likfuns = { ...
            'lik_unambigcounter_1LR_skip', ...
            'lik_unambigcounter_bayesian_1prior_skip', ...
            'lik_unambigcounter_bayesian_1prior', ...
            'lik_unambigcounter_bayesian_3prior_skip', ...
            'lik_unambigcounter_bayesian_3prior', ...
            'lik_unambigcounter_2LR_skip', ...
            'lik_unambigcounter_2LR_bias', ...
            'lik_unambigcounter_2LR_skip_3Q', ...
            'lik_unambigcounter_2LR_bias_3Q', ...
            'lik_unambigcounter_confirm_2lr'};
    elseif experiment == 2
        likfuns = { ...
            'lik_ambigcounter_1LR_skip', ...
            'lik_ambigcounter_bayesian_1prior_skip', ...
            'lik_ambigcounter_bayesian_1prior', ...
            'lik_ambigcounter_bayesian_3prior_skip', ...
            'lik_ambigcounter_bayesian_3prior', ...
            'lik_ambigcounter_2LR_skip', ...
            'lik_ambigcounter_2LR_bias', ...
            'lik_ambigcounter_2LR_skip_3Q', ...
            'lik_ambigcounter_2LR_bias_3Q'};
    else
        error('Unknown experiment number: %d. Expected 1 or 2.', experiment);
    end
end
