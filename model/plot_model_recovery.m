% plot_model_recovery.m
% Loads a saved model recovery workspace and plots:
%   (1) Model-level confusion matrix
%   (2) Family-level confusion matrix

%
% Usage: edit MAT_FILE, OUTPUT_FILE, OUTPUT_FILE_FAM below, then run.

clear; clc;

%% -- USER SETTINGS ----------------------------------------------------------
MAT_FILE        = 'results_model_recovery_ambigcounter_10tpb_6blocks_9models/workspace_20260508_183119.mat';
OUTPUT_FILE     = 'results_model_recovery_ambigcounter_10tpb_6blocks_9models/model_recovery_confusion_exp2_samprior_final.pdf';
OUTPUT_FILE_FAM = 'results_model_recovery_ambigcounter_10tpb_6blocks_9models/model_recovery_confusion_family_exp2_samprior_final.pdf';
% ----------------------------------------------------------------------------
S = load(MAT_FILE);
conf = double(S.conf);

raw = S.labels;
if iscell(raw)
    labels = cellfun(@(x) char(x), raw(:)', 'UniformOutput', false);
else
    labels = cellstr(raw);
end
labels = labels(:)';
K = numel(labels);

%% Row-normalise
conf_norm = conf ./ sum(conf, 2);

%% Colormap (shared by both figures)
n_cols = 256;
c1 = [0.98, 0.91, 0.80];   % warm cream
c2 = [0.75, 0.82, 0.88];   % dusty periwinkle
c3 = [0.25, 0.47, 0.66];   % soft slate blue
t1 = linspace(0,1,round(n_cols/2))';
t2 = linspace(0,1,n_cols-round(n_cols/2))';
cmap = [c1 + t1.*(c2-c1); c2 + t2.*(c3-c2)];

%% =========================================================================
%% FIGURE 1: Model-level confusion matrix
%% =========================================================================

ax_w  = 5.5;
ax_h  = 5.5;
lmar  = 3.5;
rmar  = 1.40;
bmar  = 2.50;
tmar  = 0.30;

fig_w = lmar + ax_w + rmar;
fig_h = bmar + ax_h + tmar;

fig = figure('Color','w','Units','inches','Position',[1 1 fig_w fig_h]);
ax  = axes('Parent', fig);

imagesc(ax, conf_norm, [0 1]);
colormap(ax, cmap);

cb = colorbar(ax);
cb.Label.String   = 'Proportion selected';
cb.Label.FontSize = 19;
cb.FontSize       = 17;

% Annotate cells
for i = 1:K
    for j = 1:K
        val = conf_norm(i,j);
        txt_color = [0 0 0]; if val > 0.5, txt_color = [1 1 1]; end
        fw = 'normal';       if i == j,    fw = 'bold';          end
        text(ax, j, i, sprintf('%d%%', round(100*val)), ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontSize', 15, 'FontWeight', fw, 'Color', txt_color);
    end
end

% Diagonal highlight
hold(ax,'on');
for i = 1:K
    rectangle(ax,'Position',[i-0.5,i-0.5,1,1],'EdgeColor','w','LineWidth',2.5);
end
hold(ax,'off');

% Axes formatting
ax.XTick               = 1:K;
ax.XTickLabel          = labels;
ax.XTickLabelRotation  = 40;
ax.YTick               = 1:K;
ax.YTickLabel          = labels;
ax.TickLabelInterpreter= 'none';
ax.FontName            = 'Helvetica';
ax.FontSize            = 17;
ax.XAxis.FontSize      = 17;
ax.YAxis.FontSize      = 17;
ax.YAxis.TickLabelGapOffset = 6;

xlabel(ax, 'Winning model (fitted)', 'FontSize', 25, 'FontName', 'Helvetica');
ylabel(ax, 'True generating model',  'FontSize', 25, 'FontName', 'Helvetica');

ax.Position = [lmar/fig_w, bmar/fig_h, ax_w/fig_w, ax_h/fig_h];

% Save
set(fig,'PaperUnits','inches','PaperSize',[fig_w fig_h],'PaperPosition',[0 0 fig_w fig_h]);
print(fig, OUTPUT_FILE, '-dpdf','-painters');
fprintf('Saved model-level plot to: %s\n', OUTPUT_FILE);

%% =========================================================================
%% FIGURE 2: Family-level confusion matrix
%% =========================================================================

% -- Define families by matching label substrings --------------------------
% Edit family names and keywords to match your label conventions.
family_defs = { ...
    'RL (1LR)', {'1LR'}; ...
    'Bayesian RL',         {'Bayes','bayes','bayesian'}; ...
    'RL (2LR)', {'2LR'}; ...
};
Kfam       = size(family_defs, 1);
fam_labels = family_defs(:,1)';

% Assign each model to a family
model_fam = zeros(1, K);
for k = 1:K
    for f = 1:Kfam
        keywords = family_defs{f,2};
        if any(cellfun(@(kw) ~isempty(strfind(labels{k}, kw)), keywords))
            model_fam(k) = f;
            break;
        end
    end
end
if any(model_fam == 0)
    warning('Some models were not assigned to a family: %s', ...
        strjoin(labels(model_fam == 0), ', '));
end

% Aggregate raw counts into family x family matrix, then row-normalise
conf_fam = zeros(Kfam, Kfam);
for i = 1:K
    for j = 1:K
        fi = model_fam(i); fj = model_fam(j);
        if fi > 0 && fj > 0
            conf_fam(fi,fj) = conf_fam(fi,fj) + conf(i,j);
        end
    end
end
conf_fam_norm = conf_fam ./ sum(conf_fam, 2);

% Same dimensions as model-level figure for panel consistency
ax_w_f = ax_w;
ax_h_f = ax_h;
lmar_f = lmar;
rmar_f = rmar;
bmar_f = bmar;
tmar_f = tmar;

fig_wf = lmar_f + ax_w_f + rmar_f;
fig_hf = bmar_f + ax_h_f + tmar_f;

fig2 = figure('Color','w','Units','inches','Position',[1 1 fig_wf fig_hf]);
ax2  = axes('Parent', fig2);

imagesc(ax2, conf_fam_norm, [0 1]);
colormap(ax2, cmap);

cb2 = colorbar(ax2);
cb2.Label.String   = 'Proportion selected';
cb2.Label.FontSize = 19;
cb2.FontSize       = 17;

% Annotate
for i = 1:Kfam
    for j = 1:Kfam
        val = conf_fam_norm(i,j);
        txt_color = [0 0 0]; if val > 0.5, txt_color = [1 1 1]; end
        fw = 'normal';       if i == j,    fw = 'bold';          end
        text(ax2, j, i, sprintf('%d%%', round(100*val)), ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontSize', 16, 'FontWeight', fw, 'Color', txt_color);
    end
end

% Diagonal highlight
hold(ax2,'on');
for i = 1:Kfam
    rectangle(ax2,'Position',[i-0.5,i-0.5,1,1],'EdgeColor','w','LineWidth',2.5);
end
hold(ax2,'off');

% Axes formatting
ax2.XTick               = 1:Kfam;
ax2.XTickLabel          = fam_labels;
ax2.XTickLabelRotation  = 30;
ax2.YTick               = 1:Kfam;
ax2.YTickLabel          = fam_labels;
ax2.TickLabelInterpreter= 'none';
ax2.FontName            = 'Helvetica';
ax2.FontSize            = 17;
ax2.XAxis.FontSize      = 17;
ax2.YAxis.FontSize      = 17;
ax2.YAxis.TickLabelGapOffset = 6;

xlabel(ax2, 'Winning family (fitted)', 'FontSize', 25, 'FontName', 'Helvetica');
ylabel(ax2, 'True generating family',  'FontSize', 25, 'FontName', 'Helvetica');

ax2.Position = [lmar_f/fig_wf, bmar_f/fig_hf, ax_w_f/fig_wf, ax_h_f/fig_hf];

% Save
set(fig2,'PaperUnits','inches','PaperSize',[fig_wf fig_hf],'PaperPosition',[0 0 fig_wf fig_hf]);
print(fig2, OUTPUT_FILE_FAM, '-dpdf','-painters');
fprintf('Saved family-level plot to: %s\n', OUTPUT_FILE_FAM);