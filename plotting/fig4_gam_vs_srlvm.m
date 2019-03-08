% user variables

datasets = [1, 2, 3]; % v1
% datasets = [11, 12, 13]; % pfc

model_dir = '';
num_folds = 5;
num_xvs = 5;
num_datasets = length(datasets);

model_strs = {'ind', 'aff-pop_01_01', 'add_10-04'};
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
    
    % load data and get firing rates
    [expt_struct, data, trial_ids, ~, ~] = loadData(dataset);
    frs{ds} = mean(data, 1);
        
    for i = 1:num_models       
        filename = sprintf('fit_gam_%s%s.mat', model_strs{i}, custom_ext);   
        file_loc = fullfile( ...
            results_dir, dataset, xv_dir, model_dir, sub_dir, filename);
        if ~exist(file_loc, 'file')
            warning('"%s" does not exits; skipping', file_loc)
            r2s{ds, i} = NaN;
            continue
        else
            load(file_loc, ...
                'meas_gam', 'fits_gam', 'net_arch', 'data_struct', ...
                'net_io')
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

%% plot 3 [QI_{Affine}/(QI_{Affine}-QI_{SRLVM}) vs psth R2]
% color points by affine QI

b = [     0    0.4470    0.7410]; % 0 114 189
r = [0.8500    0.3250    0.0980]; % 217 83 25
y = [0.9290    0.6940    0.1250]; % 237 177 32
p = [0.4940    0.1840    0.5560]; % 126 47 142
g = [0.4660    0.6740    0.1880]; % 119 172 48
colors = {b, r, g};

plot_diff = 1;

figure;

% tidy up model strings
assign_line_properties;
fontsize = 8;
      
qi_all = cell(num_models, 1);
for m = 1:num_models
    qi_all{m} = [];
end
psth_all = [];

for ds = 1:num_datasets
    
    % qis (and their diffs): 1 - aff; 2 - srlvm; 3 - diff
    idx.ind = 1;
    idx.aff = 2;
    idx.srlvm = 3;
    
    % psth
    x0 = mean(r2s{ds, idx.ind}, 2);
    psth_all = [psth_all; x0(:)];
    
    % aff
    x1 = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ (1 - r2s{ds, idx.ind});
    x1 = mean(x1, 2);
    qi_all{1} = [qi_all{1}; x1(:)];
    
    % srlvm
    x2 = (r2s{ds, idx.srlvm} - r2s{ds, idx.ind}) ./ (1 - r2s{ds, idx.ind});
    x2 = mean(x2, 2);
    qi_all{2} = [qi_all{2}; x2(:)];
    
end

num_neurons = length(psth_all);
cmap = colormap;

for n = 1:num_neurons

    if plot_diff
        y = qi_all{1}(n) - qi_all{2}(n);
        y_label = 'QI (Affine) - QI (SRLVM-4)';
        y_lim = [-0.2, 0.4];
    else
        y = qi_all{1}(n);
        y_label = 'QI (Affine)';
        y_lim = [0, 0.7];
    end
    
    % get point color
    indx = 1;
    max_val = max(qi_all{indx});
    min_val = 0; %quantile(qi_all{indx}, 0.05);
    if qi_all{indx}(n) < min_val
        continue
    end
    if qi_all{2}(n) < 0 || qi_all{1}(n) < 0
        continue
    end
    range_qi =  max_val - min_val;
    color_index = ceil((qi_all{indx}(n) - min_val) / range_qi * 56);
    if color_index == 0
        color_index = 1;
    end
    point_color = cmap(color_index, :);

    % R^2 ind
    x = psth_all(n);
    x_label = 'PSTH R^2';
    semilogx(x, y, '.', 'color', point_color)
    xlabel(x_label)
    xlim([1e-2, 1])
    ylabel(y_label)
    ylim([-0.1, 0.15])
    clean_plot
    hold on
    
end

cb = colorbar;
set(cb, 'YTick', [0, 0.5, 1.0], 'YTickLabel', [0, 0.35, 0.7])
ylabel(cb, 'QI (Affine)')
