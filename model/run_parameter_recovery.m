function run_parameter_recovery(workspace_mat, g, m, outdir_override, param_names_override)
% RUN_PARAMETER_RECOVERY
% Plot and summarize parameter recovery for generator g (and model m).
%
% Usage:
%   run_parameter_recovery('path/to/workspace_YYYYMMDD_HHMMSS.mat', 6)
%   run_parameter_recovery('...mat', 6, 6)
%   run_parameter_recovery('...mat', 6, 6, 'my_outdir')
%   run_parameter_recovery('...mat', 6, 6, [], {'invtemp','lr_pos','lr_neg','sticky'})
% 
% To run with all matched generator models:
% S = load('path/to/workspace_20240101_120000.mat');
% Kmods = numel(S.labels);
% 
% for g = 1:Kmods
%     run_parameter_recovery('path/to/workspace_20240101_120000.mat', g);
% end

% To run for Dorfman & Bhui Experiment 1 (main text experiment),
% run this in command window:
% workspace_path = 'results_model_recovery_10tpb_6blocks_10models/workspace_20260508_221809.mat';
% exp_name       = 'exp56_param_recovery';
% 
% S     = load(workspace_path);
% Kmods = numel(S.labels);
% 
% for g = 1:Kmods
%     run_parameter_recovery(workspace_path, g, g, exp_name);
% end

% To run for Dorfman & Bhui Experiment 2 (supplemental experiment):
% run this in command window:
% workspace_path = 'results_model_recovery_ambigcounter_10tpb_6blocks_9models/workspace_20260508_183119.mat';
% exp_name       = 'exp50_param_recovery';
% 
% S     = load(workspace_path);
% Kmods = numel(S.labels);
% 
% for g = 1:Kmods
%     run_parameter_recovery(workspace_path, g, g, exp_name);
% end
%
% Inputs:
%   workspace_mat          : path to the saved workspace_*.mat from run_model_recovery
%   g                      : generator index (1..9)
%   m   (optional)         : model index to evaluate (default = g)
%   outdir_override        : optional output directory for plots/CSVs
%   param_names_override   : optional cellstr of parameter names (length K)
%
% Outputs:
%   Saves figures (.png/.fig) and a CSV with r, slope, intercept per param.

if nargin < 2 || isempty(g)
    error('Provide generator index g (1..9).');
end
if nargin < 3 || isempty(m)
    m = g;
end

% ---------------- Load workspace ----------------
S = load(workspace_mat);

% Basic checks
needFields = {'AllRes','labels'};
for f = 1:numel(needFields)
    if ~isfield(S, needFields{f})
        error('Workspace missing required field "%s". Re-run run_model_recovery with the latest script.', needFields{f});
    end
end

labels = S.labels;
Kmods  = numel(labels);
if g<1 || g>Kmods || m<1 || m>Kmods
    error('g and m must be between 1 and %d', Kmods);
end

% ---------------- Collect recovered params (Xrec) ----------------
Res_gm = S.AllRes{g}{m};     % struct array (N x 1), each has .x
if ~isfield(Res_gm, 'x')
    error('This workspace does not contain fitted parameter vectors (.x). Re-run run_model_recovery with the updated code that stores .x.');
end
Xrec = vertcat(Res_gm.x);    % [N x Krec]

% ---------------- Collect ground-truth params (Xtrue) ----------------
% Prefer a ThetaCell if present; otherwise, assemble from Theta1..Theta9.
if isfield(S, 'ThetaCell')
    ThetaCell = S.ThetaCell;
else
    % Make a ThetaCell from Theta1..Theta9 if available
    ThetaCell = cell(1, Kmods);
    for j = 1:Kmods
        nm = sprintf('Theta%d', j);
        if isfield(S, nm), ThetaCell{j} = S.(nm); end
    end
end

if g <= numel(ThetaCell) && ~isempty(ThetaCell{g})
    Xtrue = ThetaCell{g};
else
    % Fallback: try canonical ThetaX name
    nm = sprintf('Theta%d', g);
    if isfield(S, nm)
        Xtrue = S.(nm);
    else
        error('Could not find true parameter matrix for generator g=%d (ThetaCell{%d} or %s).', g, g, nm);
    end
end

% Sanity: keep common columns only (some models add Q-inits, etc.)
K = min(size(Xtrue,2), size(Xrec,2));
Xtrue = Xtrue(:, 1:K);
Xrec  = Xrec(:,  1:K);

% ---------------- Parameter names ----------------
if nargin >= 5 && ~isempty(param_names_override)
    pnames = param_names_override(:)';
elseif isfield(Res_gm, 'param_names') && ~isempty(Res_gm(1).param_names)
    pnames = Res_gm(1).param_names(:)';     % if your workspace saved them
else
    % Fallback generic names
    pnames = arrayfun(@(k)sprintf('param%d',k), 1:K, 'UniformOutput', false);
end
if numel(pnames) ~= K
    warning('Length of parameter names (%d) does not match K (%d); using generic names.', numel(pnames), K);
    pnames = arrayfun(@(k)sprintf('param%d',k), 1:K, 'UniformOutput', false);
end

% ---------------- Output directory ----------------
if nargin < 4 || isempty(outdir_override)
    base = fileparts(workspace_mat);
    if isempty(base), base = pwd; end
    ts   = datestr(now,'yyyymmdd_HHMMSS');
    outdir = fullfile(base, sprintf('param_recovery_%s_g%02d_m%02d', ts, g, m));
else
    outdir = outdir_override;
end
if ~exist(outdir,'dir'), mkdir(outdir); end

% ---------------- Compute stats and plot ----------------
N = size(Xtrue,1);
ncols = min(4, K); nrows = ceil(K/ncols);

% Stats table: param, r, slope, intercept, RMSE
stats_tbl = cell(K,5);

h = figure('Name', sprintf('Parameter recovery: gen=%s | fit=%s', labels{g}, labels{m}), ...
           'Color','w', 'Position', get(0,'Screensize'));
for k = 1:K
    xt = Xtrue(:,k);
    xr = Xrec(:,k);

    % Pearson r (rows complete)
    r = corr(xt, xr, 'type','Pearson','rows','complete');

    % OLS: xr = b0 + b1 * xt
    X = [ones(N,1) xt];
    b = X \ xr; b0 = b(1); b1 = b(2);

    % RMSE
    rmse = sqrt(mean((xr - (b0 + b1*xt)).^2));

    % Plot
    subplot(nrows, ncols, k);
    plot(xt, xr, 'o', 'MarkerSize', 5); hold on;

    % Identity + regression line
    lims = [min([xt; xr]) max([xt; xr])];
    if ~all(isfinite(lims)) || lims(1)==lims(2)
        lims = [min(xt)-1, max(xt)+1];
    end
    plot(lims, lims, '--');                 % identity
    plot(lims, b0 + b1*lims, '-');          % regression
    xlabel('True'); ylabel('Recovered');
    title(sprintf('%s | r=%.2f, slope=%.2f', pnames{k}, r, b1));
    grid on; axis tight;

    % Store stats
    stats_tbl{k,1} = pnames{k};
    stats_tbl{k,2} = r;
    stats_tbl{k,3} = b1;
    stats_tbl{k,4} = b0;
    stats_tbl{k,5} = rmse;
end

sgtitle(sprintf('Parameter recovery ? True gen: %s  |  Fit: %s  (N=%d)', labels{g}, labels{m}, N));

% Save figure
pngf = fullfile(outdir, sprintf('param_recovery_g%02d_%s__m%02d_%s.png', g, labels{g}, m, labels{m}));
figf = fullfile(outdir, sprintf('param_recovery_g%02d_%s__m%02d_%s.fig', g, labels{g}, m, labels{m}));
saveas(h, pngf); saveas(h, figf);
close(h);

% Save CSV
Tstats = cell2table(stats_tbl, 'VariableNames', {'param','pearson_r','slope','intercept','rmse'});
csvf = fullfile(outdir, sprintf('param_recovery_stats_g%02d_%s__m%02d_%s.csv', g, labels{g}, m, labels{m}));
writetable(Tstats, csvf);

% Also print to console
fprintf('\nParameter recovery stats (gen=%s, fit=%s):\n', labels{g}, labels{m});
for k = 1:K
    fprintf('  %-12s  r=%6.3f  slope=%7.3f  intercept=%7.3f  RMSE=%7.3f\n', ...
        pnames{k}, Tstats.pearson_r(k), Tstats.slope(k), Tstats.intercept(k), Tstats.rmse(k));
end

end
