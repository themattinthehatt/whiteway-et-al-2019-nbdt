b = [     0    0.4470    0.7410]; % 0 114 189
r = [0.8500    0.3250    0.0980]; % 217 83 25
y = [0.9290    0.6940    0.1250]; % 237 177 32
p = [0.4940    0.1840    0.5560]; % 126 47 142
g = [0.4660    0.6740    0.1880]; % 119 172 48

colors = [b; r; y; p; g];

% user variables
model_dir = '';
% datasets = [100, 110, 120]; % 160-260
% datasets = [101, 111, 121]; % 500-1000
% datasets = [102, 112, 122]; % 060-1260
% datasets = [300, 301];
% datasets = [400, 401, 402];
% datasets = [410, 411, 412];
datasets = 122;
num_folds = 10;

xv_dir = sprintf('%02g_fold', num_folds);
dataset_strs = getDatasetStrings(datasets);
dataset = dataset_strs{1};
[data_dir, results_dir] = configProjDirs(dataset);
[expt_struct, data, trial_ids, ~, ~] = loadData(dataset);
num_neurons = size(data, 2);

%% get tuning measures

stim_indxs = expt_struct.stims;

[osi, ori_pref, dsi, dir_pref] = calcTuningMeasures(dataset);

%% get average stim response

% put responses into a 4D tensor for easier averaging
[num_reps, num_dirs] = size(trial_ids);

% chose arbitrary segment that is not first or last to get frame numbers
temp = cellfun(@(x) length(x), expt_struct.stims);
max_num_stim_frames = max(temp(:));
if ~isempty(expt_struct.blanks)
    temp = cellfun(@(x) length(x), expt_struct.blanks);
    max_num_blank_frames = max(temp(:));
else
    max_num_blank_frames = 0;
end

trials_averaged.stim = NaN(max_num_stim_frames, num_neurons, num_reps, num_dirs);
trials_averaged.blank = NaN(max_num_blank_frames, num_neurons, num_reps, num_dirs);

for i = 1:num_neurons
    for j = 1:num_reps
        for k = 1:num_dirs
            % stim
            indxs = expt_struct.stims{j,k};
            len = length(indxs);
            trials_averaged.stim(1:len, i, j, k) = data(indxs, i);
            % blanks
            if max_num_blank_frames > 0
                indxs = expt_struct.blanks{j,k};
                len = length(indxs);
                trials_averaged.blank(1:len, i, j, k) = data(indxs, i);
            end
        end
    end
end

% calculate averaged response for each direction of stimulus
stim_resp = nanmean(trials_averaged.stim, 3); % avg over reps
stim_resp = squeeze(nanmean(stim_resp, 1));   % avg over stim duration

%% plot population tuning curve

% stim_indx = 9;
% trial_nums = [134, 135];

stim_indx = 3;
trial_nums = [91, 110];
% trial_nums = [91, 110, 2, 3, 5, 8, 16, 17];
% trial_nums = [2, 3, 4];

% below requires first running cell "calc population tuning curves (no
% plotting)"
% stim_indx = best_stim_indx;
% trial_nums = [min_indxs1(best_stim_indx), min_indxs2(best_stim_indx)];

plot_avg = 0;
plot_trials = 1;
plot_tuning = 1;

figure;

osi_thresh = 0.20;

if plot_trials || plot_tuning
    
    for tn = 1:length(trial_nums)

        resp = data(stim_indxs{trial_nums(tn), stim_indx}, :);
        resp_norm = resp' ./ max(stim_resp, [], 2);
        x = ori_pref(osi > osi_thresh);
        y = resp_norm(osi > osi_thresh);
        x = x(:);
        y = y(:);
        if plot_trials
            plot(x, y, '.', ...
                'MarkerFaceColor', colors(tn, :), ...
                'MarkerEdgeColor', colors(tn, :), ...
                'MarkerSize', 10)
            hold on
        end

        if plot_tuning
            % fit circular gaussian
            fun1 = @(x, y, p) ...
                norm(y - exp(p(1) * cos(2 * x * pi / 180 - p(2))) ...
                / (2 * pi * besseli(0, p(1))) - p(3));
            fun2 = @(p) fun1(x, y, p);
            p0 = [1, pi / 2, 0];

            p1 = fminsearch(fun2, p0);

            % plot circular gaussian
            xs = linspace(0, 180, 100);
            ys = exp(p1(1) * cos(2 * xs * pi / 180 - p1(2))) ...
                / (2 * pi * besseli(0, p1(1))) + p1(3);
            if tn < 3
                line_color = colors(tn, :);
                line_width = 2;
            else
                line_color = 'k';
                line_width = 1;
            end
            plot(xs, ys, 'color', line_color, 'LineWidth', line_width)
            hold on
        end
    end
end

% plot mean responses
if plot_avg
    resp = stim_resp(:, stim_indx);
    resp_norm = resp ./ max(stim_resp, [], 2);
    x = ori_pref(osi > osi_thresh);
    y = resp_norm(osi > osi_thresh);
    x = x(:);
    y = y(:);
    %plot(dir_pref(dsi > 0.05), resp_norm(dsi > 0.05), '.')
    plot(x, y, '.')
    hold on

    % fit circular gaussian
    fun1 = @(x, y, p) ...
        norm(y - exp(p(1) * cos(2 * x * pi / 180 - p(2))) ...
        / (2 * pi * besseli(0, p(1))) - p(3));
    fun2 = @(p) fun1(x, y, p);

    p0 = [1, pi / 2, 0];

    p1 = fminsearch(fun2, p0);

    % plot circular gaussian
    xs = linspace(0, 180, 100);
    ys = exp(p1(1) * cos(2 * xs * pi / 180 - p1(2))) ...
        / (2 * pi * besseli(0, p1(1))) + p1(3);
    plot(xs, ys)
end

fontsize = 12;
clean_plot
xlim([-5, 185])
xticks([0, 45, 90, 135, 180])
ylim([0, 1.5])
xlabel('Preferred orientation (deg)')
ylabel(sprintf('Normalized\nresponse'))
title(sprintf('monkey %i, stim %i, trials %i/%i', ...
    datasets, stim_indx, trial_nums(:)))
    
%% cycle through individual tuning curves

stims = 0:30:330;
num_rows = 5;
num_iters = ceil(num_neurons / num_rows);

figure;
indx = 1;
for iter = 1:num_iters
    for row = 1:num_rows
        subplot(num_rows, 1, row)
        cla
        
        % plot means
        x = stims;
        y = stim_resp(indx, :);
        x = x(:);
        y = y(:);
        plot(x, y, '.k');
        hold on;
        
        % plot fitted von mises
        fun1 = @(x, y, p) ...
        norm(y - ( ...
            exp(p(1) * cos(x * pi / 180 - p(2))) ... % von mises 1
            .../ (2 * pi * besseli(0, p(1))) ...
            + exp(p(3) * cos(x * pi / 180 - p(4))) ... % von mises 1
            .../ (2 * pi * besseli(0, p(3))) ...
            + p(5))); % bias
        fun2 = @(p) fun1(x, y, p);

        p0 = [1, pi, 1, 0, 0];

        p1 = fminsearch(fun2, p0);

        % plot circular gaussian
        xs = linspace(0, 360, 200);
        ys = exp(p1(1) * cos(xs * pi / 180 - p1(2))) ...
                .../ (2 * pi * besseli(0, p1(1))) ...
                + exp(p1(3) * cos(xs * pi / 180 - p1(4))) ...
                .../ (2 * pi * besseli(0, p1(3))) ...
                + p1(5);
        plot(xs, ys)
        
        title(sprintf('Cell #%i', indx))
        indx = indx + 1;
    end
    pause
end

%% calc population tuning curve fits (no plotting)

osi_thresh = 0.20;

[num_reps, num_stims] = size(trial_ids);

fvals = NaN(num_reps, num_stims);
for stim = 1:num_stims
    for rep = 1:num_reps

        resp = data(stim_indxs{rep, stim}, :);
        resp_norm = resp' ./ max(stim_resp, [], 2);
        x = ori_pref(osi > osi_thresh);
        y = resp_norm(osi > osi_thresh);
        x = x(:);
        y = y(:);
        
        % fit circular gaussian
        fun1 = @(x, y, p) ...
            norm(y - exp(p(1) * cos(2 * x * pi / 180 - p(2))) ...
            / (2 * pi * besseli(0, p(1))) - p(3));
        fun2 = @(p) fun1(x, y, p);

        p0 = [1, pi / 2, 0];
        [p1, fvals(rep, stim)] = fminsearch(fun2, p0);

    end
end

% find "best" 
[mins1, min_indxs1] = min(fvals, [], 1);
for i = 1:length(min_indxs)
    fvals(min_indxs1(i), i) = 1000;
end
[mins2, min_indxs2] = min(fvals, [], 1);

[best_stim_val, best_stim_indx] = min(mean([mins1; mins2], 1));

%% cycle through pop tuning curves

osi_thresh = 0.20;

stim_indx = 3;

num_rows = 5;
num_iters = ceil(num_reps / num_rows);

figure;
indx = 1;
for iter = 1:num_iters
    for row = 1:num_rows
        subplot(num_rows, 1, row)
        cla
        
        % plot population tuning curve
        resp = data(stim_indxs{indx, stim_indx}, :);
        resp_norm = resp' ./ max(stim_resp, [], 2);
        x = ori_pref(osi > osi_thresh);
        y = resp_norm(osi > osi_thresh);
        x = x(:);
        y = y(:);
        plot(x, y, '.')
        hold on

        % fit circular gaussian
        fun1 = @(x, y, p) ...
            norm(y - exp(p(1) * cos(2 * x * pi / 180 - p(2))) ...
            / (2 * pi * besseli(0, p(1))) - p(3));
        fun2 = @(p) fun1(x, y, p);

        p0 = [1, pi / 2, 0];

        p1 = fminsearch(fun2, p0);

        % plot circular gaussian
        xs = linspace(0, 180, 100);
        ys = exp(p1(1) * cos(2 * xs * pi / 180 - p1(2))) ...
            / (2 * pi * besseli(0, p1(1))) + p1(3);
        plot(xs, ys)
        ylim([0, 2])
        
        title(sprintf('Repeat #%i', indx))
        indx = indx + 1;
    end
    pause
end

%% plot individual tuning w/ individual trials
% NOTES: 
% 1) need to run 'get average stim response' cell first to plot data
% 2) need to run '' cell first to plot model predictions


stims = 0:30:330;
num_stims = length(stims);
fit_vonmises = 0;
use_scatter = 1;
plot_data = 1; % 0 to plot model prediction
indx = 89;
% 112 - 9, 28, 69

data_line_color = [0, 0, 0];
data_scatter_color = [0.5, 0.5, 0.5];
if plot_data
    line_color = data_line_color;
    scatter_color = data_scatter_color;
else
    line_color = [0, 0, 0.8];
    scatter_color = 'b';
end

figure;
    
if plot_data
    resps = data;
else
    resps = pred{3, 2}.^2;
end

% === plot repeats
resps2 = NaN(200, 12);
for stim = 1:num_stims
    stim_indxs = [trial_ids{:, stim}];
    if use_scatter
        scatter( ...
            repmat(stims(stim), ...
            length(stim_indxs), 1), resps(stim_indxs, indx), 5, 'filled', ...
            'jitter', 'on', 'jitterAmount', 3, ...
            'markerfacecolor', scatter_color)
        hold on;
    %plot(stims(stim), data(stim_indxs, indx), '.r')
    else
        resps2(:, stim) = resps(stim_indxs, indx);
    end
end
if ~use_scatter
    boxplot(resps2, 'positions', stims, 'plotstyle', 'compact', ...
        'whisker', 1)
    hold on
end

% === plot means
trials_averaged.stim = NaN(max_num_stim_frames, num_neurons, num_reps, num_dirs);
for i = 1:num_neurons
    for j = 1:num_reps
        for k = 1:num_dirs
            % stim
            indxs = expt_struct.stims{j,k};
            len = length(indxs);
            trials_averaged.stim(1:len, i, j, k) = resps(indxs, i);
        end
    end
end

% calculate averaged response for each direction of stimulus
stim_resp = nanmean(trials_averaged.stim, 3); % avg over reps
stim_resp = squeeze(nanmean(stim_resp, 1));   % avg over stim duration

x = stims;
y = stim_resp(indx, :);
x = x(:);
y = y(:);
plot(x, y, '.', 'MarkerSize', 20, 'color', line_color);

% save data tuning curve
if plot_data
    x_tuning_data = x;
    y_tuning_data = y;
end

% === plot tuning curves
if fit_vonmises
    % fit von mises
    fun1 = @(x, y, p) ...
    norm(y - ( ...
        exp(p(1) * cos(x * pi / 180 - p(2))) ... % von mises 1
        + exp(p(3) * cos(x * pi / 180 - p(4))) ... % von mises 1
        + p(5))); % bias
    fun2 = @(p) fun1(x, y, p);

    p0 = [1, pi, 1, 0, 0];

    p1 = fminsearch(fun2, p0);

    xs = linspace(0, 360, 100);
    ys = exp(p1(1) * cos(xs * pi / 180 - p1(2))) ...
            + exp(p1(3) * cos(xs * pi / 180 - p1(4))) ...
            + p1(5);
    plot(xs, ys, 'linewidth', 2, 'color', line_color)
else
    % connect the means
    plot(x, y, '-', 'linewidth', 2, 'color', line_color)
end

if ~plot_data && exist('x_tuning_data', 'var')
    % plot data tuning curve
    plot(x_tuning_data, y_tuning_data, ...
        '--', 'linewidth', 2, 'color', data_line_color)
end

title(sprintf('Cell #%i', indx))
xlim([0, 360])
xlabel('Grating direction (degrees)')
if plot_data
    ylabel('Observed spike count')
else
    ylabel('Expected spike count')
end
indx = indx + 1;
