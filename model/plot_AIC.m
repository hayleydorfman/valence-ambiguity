% Barplot to compare AIC values for models

% Example AIC values for 5 models (assuming the number of subjects or observations is 100)
num_subjects = length(data);  % Adjust this according to your dataset size

% Calculate the mean AIC for each model
mean_aic_values = [
    sum(results(1).aic) / num_subjects,  % Model 1 Mean AIC
    sum(results(2).aic) / num_subjects,  % Model 2 Mean AIC
    sum(results(3).aic) / num_subjects,  % Model 3 Mean AIC
    sum(results(4).aic) / num_subjects,  % Model 4 Mean AIC
    sum(results(5).aic) / num_subjects   % Model 5 Mean AIC
];

% Define model names with variable names
model_names = {'1 learning rate', '1-prior Bayes (skip)', '1-prior Bayes', '3-prior Bayes (skip)', '3-prior Bayes'};


custom_colors = [

      hex2rgb('#BAD6F3'); %1 LR
      hex2rgb('#67ABF0'); %Bayes 1 prior skip
      hex2rgb('#2281E0'); %Bayes 1 prior
      hex2rgb('#0E569E'); %Bayes 3 prior skip
      hex2rgb('#234261'); %Bayes 3 prior
          
];



% Create the bar plot
figure;
hBar = bar(mean_aic_values, 'FaceColor', 'flat');

% Set individual bar colors using the 'CData' property
hBar.FaceColor = 'flat'; % Ensure FaceColor is set to flat (to use CData)
hBar.CData = custom_colors; % Assign custom colors to each bar

% Set X tick positions and labels BEFORE setting label font size
set(gca, 'XTick', 1:length(model_names));
set(gca, 'XTickLabel', model_names);

% Set tick label size (NOT axis labels)
set(gca, 'FontSize', 18);  % this affects only tick marks

% Add labels
xlabel('Comparison Models', 'FontSize', 35, 'FontWeight', 'bold');
ylabel('Mean AIC', 'FontSize', 35, 'FontWeight', 'bold');


% Dynamically set y-axis limits based on the data
y_padding = 2;  % Adjust the padding for the y-axis
ylim([min(mean_aic_values) - y_padding, max(mean_aic_values) + y_padding]);

% Add a grid for better readability
grid on;

% Increase the font size for readability
%set(gca, 'FontSize', 30);

% Improve the appearance of the plot for publication
set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.5);

% Add the Mean AIC text labels above the bars
for i = 1:length(mean_aic_values)
    % Display the mean AIC value at the top of each bar
    text(i, mean_aic_values(i) + .2, ...
        sprintf('%.2f', mean_aic_values(i)), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', 18, 'FontWeight', 'bold');
end

% Set the figure window size (width and height in pixels)
set(gcf, 'Position', [100, 100, 1600, 500]);  % Make the figure wider

% Set the paper size to match the figure size
set(gcf, 'PaperSize', [16, 5]);  % Adjust the paper size (width x height in inches)

% Set the paper position to control the figure's placement on the page
set(gcf, 'PaperPosition', [0 0 16 5]);  % Set position and size on the page (width x height in inches)

% Now save the figure as a PDF
saveas(gcf, 'plot_output.pdf');  % Save as PDF

% Display the plot
hold off;

% Helper function to convert hex to RGB
function rgb = hex2rgb(hex)
    hex = char(hex); % Ensure the input is a character array
    rgb = reshape(sscanf(hex(2:end), '%2x') / 255, 1, 3); % Convert to RGB
end
