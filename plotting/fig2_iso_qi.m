%% iso-QI plot

datasets = [1, 2, 3]; % v1
% datasets = [11, 12, 13]; % pfc

model_dir = '';
num_folds = 5;
num_xvs = 5;
num_datasets = length(datasets);

model_strs = {'ind', 'add_04'};
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
            r2s{ds, i} = NaN;
            continue
        else
            load(file_loc, 'meas_gam')
        end

        num_xvs = length(meas_gam.r2s);
        num_neurons = length(meas_gam.r2s{1});
        r2s_temp = NaN(num_neurons, num_xvs);
        for nxv = 1:num_xvs
            r2s_temp(:, nxv) = meas_gam.r2s{nxv};
        end
        r2s{ds, i} = mean(r2s_temp, 2); % avg over xvs
        
    end % num_models
end % num_datasets

%% plot

blu = [     0    0.4470    0.7410]; % 0 114 189
red = [0.8500    0.3250    0.0980]; % 217 83 25
gre = [0.4660    0.6740    0.1880]; % 119 172 48

colors = {blu, red, gre};
fontsize = 8;

figure;

% plot model r2s
for ds = 1:3
    r2_stim = mean(r2s{ds, 1}, 2);
    r2_model = mean(r2s{ds, 2}, 2);
    plot(r2_stim, r2_model, '.', 'color', colors{ds})
    hold on
end

% plot iso-qi lines
r2stim = linspace(0, 1, 2);
qi_levels = [0, 0.25, 0.5, 0.75, 1];
for qi = qi_levels
    r2model = r2stim + qi * (1 - r2stim);
    plot(r2stim, r2model, 'k')
end

xlabel('PSTH R^2')
ylabel('RLVM R^2')
clean_plot

% highlight selected cells (lazy for now, assumes using cell(s) from last
% monkey)
cells = [89];

for i = cells
    plot(r2_stim(i), r2_model(i), '.k', 'MarkerSize', 20)
end
