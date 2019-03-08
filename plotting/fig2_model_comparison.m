% user variables

datasets = [1, 2, 3]; % v1
% datasets = [11, 12, 13]; % pfc

model_dir = '';
num_folds = 5;
num_xvs = 5;
num_datasets = length(datasets);

model_strs = { ...
    'ind', ... % independent model for calculating qi
    'add_01', 'add_02', 'add_03', 'add_04', ...
    'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', ...
    };
num_models = length(model_strs);
sub_dir = '';
custom_ext = '';

r2s = cell(num_datasets, num_models);

%% iterate through datasets
xv_dir = sprintf('%02g_fold', num_folds);
dataset_strs = getDatasetStrings(datasets);

for ds = 1:num_datasets

    dataset = dataset_strs{ds};
    [data_dir, results_dir] = configProjDirs(dataset);
        
    for i = 1:num_models       
        filename = sprintf('fit_gam_%s%s.mat', model_strs{i}, custom_ext);   
        file_loc = fullfile( ...
            results_dir, dataset, xv_dir, model_dir, sub_dir, filename);
        if ~exist(file_loc, 'file')
            warning('"%s" does not exits; skipping', file_loc)
            continue
        else
            % only load what is necessary
            load(file_loc, 'meas_gam')
        end

        num_xvs = length(meas_gam.r2s);
        num_neurons = length(meas_gam.r2s{1});
        r2s_temp = NaN(num_neurons, num_xvs);
        for nxv = 1:num_xvs
            r2s_temp(:, nxv) = meas_gam.r2s{nxv};
        end
        r2s{ds, i} = r2s_temp;
        
    end % num_models
end % num_datasets

%% plot

b = [     0    0.4470    0.7410]; % 0 114 189
r = [0.8500    0.3250    0.0980]; % 217 83 25
y = [0.9290    0.6940    0.1250]; % 237 177 32
p = [0.4940    0.1840    0.5560]; % 126 47 142
g = [0.4660    0.6740    0.1880]; % 119 172 48

figure;

% tidy up model strings
assign_line_properties;
      
for ds = 1:num_datasets

    subplot(num_datasets, 1, ds);

    % collect r2s for all models
    vals = cell(num_models, 1);
    for i = 1:num_models
        vals{i} = mean(r2s{ds, i}, 1); % avg r2s over neurons
    end

    % calculate qi
    vals_mat = NaN(length(vals{1}), num_models);
    legend_str = {};
    colors = [];
    for i = 1:num_models
        vals_mat(:, i) = ...
            (vals{i}(:) - vals{1}(:)) ./ ...
            (1 - vals{1}(:));
        legend_str = [legend_str, model_strs2{i}];
        colors = [colors; model_colors{i}];
    end
    
    % calculate means and standard deviations over xv folds
    means = mean(vals_mat, 1);
    stds = std(vals_mat, [], 1) / sqrt(size(vals_mat, 1));

    % plot qis of (s)rlvm models
    idx = (num_models - 1) / 2;
    errorbar(means(2:idx+1), stds(2:idx+1))
    hold on
    errorbar(means(idx+2:end), stds(idx+2:end))

    xlabel('Number of LVs')
    ylabel('QI')
    
    clean_plot

end
