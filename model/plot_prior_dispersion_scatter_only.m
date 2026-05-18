function plot_prior_dispersion_scatter_only(wsfile, metric, savepath)
% Saves a publication-ready scatter plot of true prior dispersion vs ?AIC,
% using ONLY generator #5 ('Bayes-3prior') datasets.
%
% USAGE:
%   plot_prior_dispersion_scatter('.../workspace.mat');
%   plot_prior_dispersion_scatter(..., 'maxmin');
%   plot_prior_dispersion_scatter(..., 'avgabs', 'my_figure.pdf');
%
% metric:   'avgabs' (default) or 'maxmin'
% savepath: optional output path (e.g., 'fig1.pdf', 'fig1.svg', 'fig1.png')

if nargin < 2 || isempty(metric),   metric   = 'avgabs'; end
if nargin < 3 || isempty(savepath), savepath = '';        end

S = load(wsfile);

idx_1prior = 3;
idx_3prior = 5;
g          = 5;

C = set_colors();

% ---------- Ground-truth prior means for generator 5 ----------
N  = numel(S.D{g});
TH = S.ThetaCell{g};
mu = TH(:, 4:6);

switch lower(metric)
    case 'avgabs'
        d12 = abs(mu(:,1) - mu(:,2));
        d13 = abs(mu(:,1) - mu(:,3));
        d23 = abs(mu(:,2) - mu(:,3));
        disp_val = (d12 + d13 + d23) / 3;
        xlbl = 'True prior dispersion (mean |{\it\mu_i} - {\it\mu_j}|)';
    case 'maxmin'
        disp_val = max(mu,[],2) - min(mu,[],2);
        xlbl = 'True prior dispersion (max {\it\mu} - min {\it\mu})';
    otherwise
        error('Unknown metric "%s". Use "avgabs" or "maxmin".', metric);
end

% ---------- AICs ----------
aic1 = arrayfun(@(i) S.AllRes{g}{idx_1prior}(i).aic, 1:N)';
aic3 = arrayfun(@(i) S.AllRes{g}{idx_3prior}(i).aic, 1:N)';

ok       = ~(isnan(aic1) | isnan(aic3));
disp_val = disp_val(ok);
dAIC     = aic1(ok) - aic3(ok);
win3     = dAIC > 0;

if isempty(disp_val)
    error('No valid datasets for generator #5 with AICs for models 3 & 5.');
end

% ---------- Publication aesthetics ----------
fnt      = 'Helvetica';   % clean sans-serif standard in journals
fsz_ax   = 16;            % axis tick labels
fsz_lbl  = 18;            % axis labels
fsz_leg  = 12;            % legend
fsz_ttl  = 18;            % title (if used)
mksz     = 110;            % marker size (pt^2 for scatter)
mk_alpha = 0.82;          % marker fill alpha

% Colours matched to exact hex values specified
col_1 = [34  129  224] / 255;   % #2281E0 -> 1-prior better
col_3 = [35   66   97] / 255;   % #234261 -> 3-prior better

% Override with set_colors if they exist
if isfield(C, 'col_1prior'), col_1 = C.col_1prior; end
if isfield(C, 'col_3prior'), col_3 = C.col_3prior; end

% ---------- Figure ----------
fig = figure('Color','w', ...
             'Units','inches', ...
             'Position',[1 1 5.5 4.8], ...   % single-column width ~3.5"; double ~7.5"
             'Name','prior_dispersion_vs_dAIC');

ax = axes('Parent', fig);
hold(ax, 'on');
box(ax, 'on');

% Plot 1-prior-better points first (underneath)
h1 = scatter(ax, disp_val(~win3), dAIC(~win3), mksz, ...
             'filled', ...
             'MarkerFaceColor', col_1, ...
             'MarkerEdgeColor', 'none', ...
             'MarkerFaceAlpha', mk_alpha);

% Plot 3-prior-better points on top
h3 = scatter(ax, disp_val(win3), dAIC(win3), mksz, ...
             'filled', ...
             'MarkerFaceColor', col_3, ...
             'MarkerEdgeColor', 'none', ...
             'MarkerFaceAlpha', mk_alpha);

% Zero reference line
yl = yline(ax, 0, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);

% ---------- Labels & formatting ----------
xlabel(ax, xlbl,                                    'FontSize', fsz_lbl, 'FontName', fnt);
ylabel(ax, '\DeltaAIC  =  AIC_{1-prior} - AIC_{3-prior}', ...
                                                    'FontSize', fsz_lbl, 'FontName', fnt);

set(ax, 'FontSize',  fsz_ax, ...
        'FontName',  fnt, ...
        'LineWidth', 1.0, ...
        'TickDir',   'out', ...
        'TickLength',[0.015 0.015], ...
        'XColor',    [0.15 0.15 0.15], ...
        'YColor',    [0.15 0.15 0.15], ...
        'Layer',     'top');

% Subtle shading above/below zero line
xl = xlim(ax);
yl_lim = ylim(ax);
patch(ax, [xl(1) xl(2) xl(2) xl(1)], [0 0 yl_lim(2) yl_lim(2)], ...
      col_3, 'FaceAlpha', 0.04, 'EdgeColor', 'none', 'HandleVisibility','off');
patch(ax, [xl(1) xl(2) xl(2) xl(1)], [yl_lim(1) yl_lim(1) 0 0], ...
      col_1, 'FaceAlpha', 0.04, 'EdgeColor', 'none', 'HandleVisibility','off');

% Bring scatter points to front after patch
uistack(h1, 'top');
uistack(h3, 'top');

% Legend
leg = legend(ax, [h1 h3], {'one-prior model favored', 'three-prior model favored'}, ...
             'FontSize',   fsz_leg, ...
             'FontName',   fnt, ...
             'EdgeColor',  [0.7 0.7 0.7], ...
             'Box',        'on', ...
             'Location',   'northwest');

% Tight layout
ax.Position = [0.15 0.14 0.80 0.80];

% ---------- Optional save ----------
if ~isempty(savepath)
    [~, ~, ext] = fileparts(savepath);
    switch lower(ext)
        case {'.pdf'}
            set(fig, 'PaperUnits','inches','PaperPosition',[0 0 5.5 4.8],'PaperSize',[5.5 4.8]);
            print(fig, savepath, '-dpdf', '-r0', '-bestfit');
        case {'.svg'}
            print(fig, savepath, '-dsvg', '-r0');
        case {'.png'}
            print(fig, savepath, '-dpng', '-r300');
        case {'.tif', '.tiff'}
            print(fig, savepath, '-dtiff', '-r300');
        case {'.eps'}
            print(fig, savepath, '-depsc', '-r0');
        otherwise
            saveas(fig, savepath);
    end
    fprintf('Figure saved to: %s\n', savepath);
end

end
