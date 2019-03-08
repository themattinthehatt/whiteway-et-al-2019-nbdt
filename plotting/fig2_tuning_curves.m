% user variables
model_dir = '';
datasets = 3;
num_folds = 5;

xv_dir = sprintf('%02g_fold', num_folds);
dataset_strs = getDatasetStrings(datasets);
dataset = dataset_strs{1};
[data_dir, results_dir] = configProjDirs(dataset);
[expt_struct, data, trial_ids, ~, ~] = loadData(dataset);
num_neurons = size(data, 2);

%% plot individual tuning w/ individual trials

stims = 0:30:330;
num_stims = length(stims);

indx = 89;

% put responses into a 4D tensor for easier averaging
[num_reps, num_dirs] = size(trial_ids);

% chose arbitrary segment that is not first or last to get frame numbers
temp = cellfun(@(x) length(x), expt_struct.stims);
max_num_stim_frames = max(temp(:));

figure;
    
data_line_color = [0, 0, 0];
data_scatter_color = [0.5, 0.5, 0.5];
for s = 1:2
    
    subplot(2, 2, s)
    
    if s == 1
        resps = data;
        line_color = data_line_color;
        scatter_color = data_scatter_color;
    else
        % load rlvm model
        num_lvs = 4;
        model_name = sprintf('fit_gam_add_%02i', num_lvs);
        load(fullfile(results_dir, dataset, xv_dir, model_name))        
        [pred, ~, ~, ~, ~, ~] = getGamPredictions( ...
            data_struct, net_arch, fits_gam, net_io, 0);
        resps = pred.^2;
        line_color = 0.8 * [     0    0.4470    0.7410];
        scatter_color = [     0    0.4470    0.7410];
    end

    % === plot repeats
    for stim = 1:num_stims
        stim_indxs = [trial_ids{:, stim}];
        scatter( ...
            repmat(stims(stim), ...
            length(stim_indxs), 1), resps(stim_indxs, indx), 5, 'filled', ...
            'jitter', 'on', 'jitterAmount', 3, ...
            'markerfacecolor', scatter_color)
        hold on;
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
    if s == 1
        x_tuning_data = x;
        y_tuning_data = y;
    end

    % === plot tuning curves
    % connect the means
    plot(x, y, '-', 'linewidth', 2, 'color', line_color)

    if s == 2
        % plot data tuning curve on rlvm plot
        plot(x_tuning_data, y_tuning_data, ...
            '-', 'linewidth', 2, 'color', data_line_color)
    end

    title(sprintf('Cell #%i', indx))
    xlim([0, 370])
    xlabel('Grating direction (degrees)')
    ylim([0, 30])
    if s == 1
        ylabel('Observed spike count')
    else
        ylabel('Expected spike count')
    end
    
end

%% plot expected vs observed spike counts for a specific orientation

stim = 6;

subplot(2, 2, 3)

% get observed spike counts for this stimulus
stim_indxs = [trial_ids{:, stim}];

resps_data = data(stim_indxs, indx);
resps_pred = pred(stim_indxs, indx).^2;
resps_pred_psth = repmat(mean(resps_data), size(resps_data));

% plot rlvm predictions
x = resps_data;
y = resps_pred;
x = x(:);
y = y(:);
plot(x, y, '.', 'MarkerSize', 5, 'color', line_color);
hold on

% plot psth predictions
y = resps_pred_psth;
y = y(:);
plot(x, y, '.', 'MarkerSize', 5, 'color', data_line_color);

line([0, 20], [0, 20], 'color', 'k')

title(sprintf('Grating direction %i degrees', stims(stim)))
xlim([0, 20])
xlabel('Observed spike count')
ylim([0, 20])
ylabel('Expected spike count')
