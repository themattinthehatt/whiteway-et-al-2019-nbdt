% user variables
% datasets = 1:4;
% datasets = 21:24;
% datasets = [25, 27, 29, 31, 33]; % anest
% datasets = [26, 28, 30, 32, 34]; % awake

% datasets = [100, 110, 120];
% datasets = [101, 111, 121];
datasets = 101; %101;
% datasets = [102, 112, 122];
% datasets = [200, 210, 220, 230, 240];
% datasets = [300, 301];
% datasets = [401];

model_dir = '';
num_folds = 10;
num_xvs = 10;
num_datasets = length(datasets);
new_fig = 1;
trial_avg = 1;

% standard affine models
% model_strs = {'ind', ...
%     ...'add-pop_01', 'add-popavg', ...
%     ...'mult-pop_01', 'mult-popavg', ...
%     ...'aff-pop_01', 'aff-popavg', ...
%     };

% nonlinear affine models
% model_strs = {'ind', ...
%     ...'add-pop_01', 'add-pop_05-01', 'add-pop_10-01', 'add-popavg', ...
%     ...'mult-pop_01', 'mult-pop_05-01', 'mult-pop_10-01', 'mult-popavg', ...
%     'aff-pop_01', 'aff-pop_01_oneplus', 'aff-pop_05-01', 'aff-pop_10-01', ...
%     'aff-popavg', 'aff-popavg_oneplus' ...
%     };

% standard affine models + additional predictors
% model_strs = {'ind', ...
%     'add-pop_01', 'add-popavg', ...'add-pup', 'add-run', ...
%     'mult-pop_01_oneplus', 'mult-popavg_oneplus', ...'mult-pup_oneplus', 'mult-run_oneplus', ...
%     'aff-pop_01_oneplus', 'aff-popavg_oneplus', ...'aff-pup_oneplus', 'aff-pup_oneplus', ...
%     };

% (s)rlvms
% model_strs = {... 'ind', ...
%     'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ...
%     'add_06', 'add_07', 'add_08', ...'add_09', 'add_10', ...
%     'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ...
%     'add_10-06', 'add_10-07', 'add_10-08', ...'add_10-09', 'add_10-10', ...
%     ...'add_15-01', 'add_15-02', 'add_15-03', 'add_15-04', 'add_15-05', ...
%     ...'add_15-06', 'add_15-07', 'add_15-08', 'add_15-09', 'add_15-10', ...
%     };

% (m)rlvms
% model_strs = {...'ind', ...
%     'mult-pop_01_oneplus', 'mult-pop_02_oneplus', 'mult-pop_03_oneplus', ...
%     'mult-pop_05-01_oneplus', 'mult-pop_05-02_oneplus', 'mult-pop_05-03_oneplus', ...
%     };

% stim + (s)rlvms
% model_strs = {... 'ind', ...
%     'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', ...
%     ... 'add-pop_05-01', 'add-pop_05-02', 'add-pop_05-03', ...
%     ... 'add-pop_05-04', 'add-pop_05-05', ...
%     'add-pop_10-01', 'add-pop_10-02', 'add-pop_10-03', ...
%     'add-pop_10-04', 'add-pop_10-05', ...
%     };
% model_strs = {...'ind', ...
%     'add_01', 'add_02', 'add_03', 'add_04', ...'add_05', ...
%     ...'add_06', 'add_07', 'add_08', 'add_09', ...'add_10', ...
%     'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', ...'add_10-05', ...
%     ...'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', ...'add_10-10', ...
%     };
% model_strs = {...
%     'add_01', 'add_02', 'add_03', 'add_04', 'add_05', 'add_06', 'add_07', 'add_08', ...
%     'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', 'add_10-06', 'add_10-07', 'add_10-08', ...
%     'pca_01', 'pca_02', 'pca_03', 'pca_04', 'pca_05', 'pca_06', 'pca_07', 'pca_08', ...
%     };
model_strs = {...
    'add_01', 'add_02', 'add_03', 'add_04', 'add_05', 'add_06', 'add_07', 'add_08', ...
    'pca_01', 'pca_02', 'pca_03', 'pca_04', 'pca_05', 'pca_06', 'pca_07', 'pca_08', ...
    };
% model_strs = {...'ind', ...
%     'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', ...
%     ...'add_06', 'add_07', 'add_08', 'add_09', ...'add_10', ...
%     'add-pop_10-01', 'add-pop_10-02', 'add-pop_10-03', 'add-pop_10-04', 'add-pop_10-05', ...
%     ...'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', ...'add_10-10', ...
%     };

% affine models compare nonlinearities
% model_strs = {'ind', ...
%     'mult-pop_01', 'mult-pop_01_oneplus', 'mult-popavg', 'mult-popavg_oneplus', ...
%     ...'mult-pup', 'mult-pup_oneplus', 'mult-run', 'mult-run_oneplus', ...
%     'aff-pop_01', 'aff-pop_01_oneplus', 'aff-popavg', 'aff-popavg_oneplus', ...
%     ...'aff-pup', 'aff-pup_oneplus', 'aff-run', 'aff-run_oneplus', ...
%     };

% goris/lin models compare nonlinearities
% model_strs = {'ind', ...
%     'goris-pop', 'goris-pop_oneplus', 'goris-popavg', 'goris-popavg_oneplus', ...
%     'lin-pop', 'lin-pop_oneplus', 'lin-popavg', 'lin-popavg_oneplus', ...
%     };

% compare final models
% model_strs = {'ind', ...
%     'add-pop_01', ...
%     'goris-pop_oneplus', 'mult-pop_01_oneplus', ...
%     'lin-pop_oneplus', 'aff-pop_01_oneplus', ...
%     };

% model_strs = { ...
%     ...'ind', 'add-pop_01', 'add-pop_02', 'add-pop_03', ...'add-pop_04', 'add-pop_05', ...
%     ...'mult-pop_01_oneplus', 'aff-pop_00-01_00-01', 'aff-pop_00-02_00-01', 'aff-pop_00-03_00-01', ...'aff-pop_00-04_00-01', 'aff-pop_00-05_00-01', ...
%     ...'mult-pop_02_oneplus', 'aff-pop_00-01_00-02', 'aff-pop_00-02_00-02', 'aff-pop_00-03_00-02', ...'aff-pop_00-04_00-02', 'aff-pop_00-05_00-02', ...
%     ...'mult-pop_03_oneplus', 'aff-pop_00-01_00-03', 'aff-pop_00-02_00-03', 'aff-pop_00-03_00-03', ...'aff-pop_00-04_00-03', 'aff-pop_00-05_00-03', ...
%     ...'mult-pop_04_oneplus', 'aff-pop_00-01_00-04', 'aff-pop_00-02_00-04', 'aff-pop_00-03_00-04', ...'aff-pop_00-04_00-04', 'aff-pop_00-05_00-04', ...
%     ...'mult-pop_05_oneplus', 'aff-pop_00-01_00-05', 'aff-pop_00-02_00-05', 'aff-pop_00-03_00-05', ...'aff-pop_00-04_00-05', 'aff-pop_00-05_00-05', ...
%     };
% model_strs = { ...
%     'ind', 'add-pop_10-01', 'add-pop_10-02', 'add-pop_10-03', 'add-pop_10-04', 'add-pop_10-05', ...
%     'mult-pop_10-01', 'aff-pop_10-01_10-01', 'aff-pop_10-02_10-01', 'aff-pop_10-03_10-01', 'aff-pop_10-04_10-01', 'aff-pop_10-05_10-01', ...
%     'mult-pop_10-02', 'aff-pop_10-01_10-02', 'aff-pop_10-02_10-02', 'aff-pop_10-03_10-02', 'aff-pop_10-04_10-02', 'aff-pop_10-05_10-02', ...
%     'mult-pop_10-03', 'aff-pop_10-01_10-03', 'aff-pop_10-02_10-03', 'aff-pop_10-03_10-03', 'aff-pop_10-04_10-03', 'aff-pop_10-05_10-03', ...
%     'mult-pop_10-04', 'aff-pop_10-01_10-04', 'aff-pop_10-02_10-04', 'aff-pop_10-03_10-04', 'aff-pop_10-04_10-04', 'aff-pop_10-05_10-04', ...
%     'mult-pop_10-05', 'aff-pop_10-01_10-05', 'aff-pop_10-02_10-05', 'aff-pop_10-03_10-05', 'aff-pop_10-04_10-05', 'aff-pop_10-05_10-05', ...
%     };


% model_strs = {...'ind', ...
%     'ind', 'mult-pop_01_oneplus', 'mult-pop_02_oneplus', 'mult-pop_03_oneplus', 'mult-pop_04_oneplus', 'mult-pop_05_oneplus', ...
%     'ind', 'mult-pop_10-01', 'mult-pop_10-02', 'mult-pop_10-03', 'mult-pop_10-04', 'mult-pop_10-05', ...
%     };
% model_strs = {'ind', ...
%     'add-pop_00-01', ...
%     'mult-pop_00-01', ...
%     'aff-pop_01_01', ...
%     };
% model_strs = {'ind', ...
%     'add-pop_01', ...
%     'mult-pop_01', ...
%     'aff-pop_00-01_00-01', ...
%     };

num_models = length(model_strs);

% choose plot type 
plot_type.boxplots = 0;         % model performance (r2) in boxplot form
plot_type.errorbars = 1;        % model performance (r2) in errorbar form
plot_type.coupling_scatter = 0; % scatter of add/mult weights in aff models
                                % 1: avg over xv; 2: all xvs; 3: all expts
plot_type.lvs_scatter = 0;      % scatter of add/mult lvs in aff models
                                % 1: sep expts; 2: comb expts
plot_type.coupling_vs_pref = 0; % coupling versus ori/dir preference
                                % 1: sep expts, avg over xv; 2: comb expts

% initialize variables                            
if plot_type.boxplots == 1 || plot_type.errorbars == 1
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.coupling_scatter
    sub_dir = '';
    custom_ext = '';
    coupling = cell(num_datasets, 2);
end
if plot_type.lvs_scatter
    sub_dir = '';
    custom_ext = '';
    lvs = cell(num_datasets, 2);
end
if plot_type.coupling_vs_pref == 1
    sub_dir = '';
    custom_ext = '';
    ori_pref = cell(num_datasets, 1);
    dir_pref = cell(num_datasets, 1);
    osi = cell(num_datasets, 1);
    dsi = cell(num_datasets, 1);
    coupling = cell(num_datasets, 2);
end

%% iterate through datasets
xv_dir = sprintf('%02g_fold', num_folds);
dataset_strs = getDatasetStrings(datasets);

for ds = 1:num_datasets

    dataset = dataset_strs{ds};
    [data_dir, results_dir] = configProjDirs(dataset);
    if trial_avg == 1 && dataset(1) == 'K'
        dataset = sprintf('%s_avg', dataset);
    end
        
    for i = 1:num_models       
        filename = sprintf('fit_gam_%s%s.mat', model_strs{i}, custom_ext);   
        file_loc = fullfile( ...
            results_dir, dataset, xv_dir, model_dir, sub_dir, filename);
        if ~exist(file_loc, 'file')
            warning('"%s" does not exits; skipping', file_loc)
            continue
        else
            % only load what is necessary
            if plot_type.boxplots == 1 || plot_type.errorbars == 1
                load(file_loc, 'meas_gam')
            elseif plot_type.lvs_scatter || plot_type.coupling_scatter
                load(file_loc, ...
                    'meas_gam', 'fits_gam', 'net_arch', 'data_struct')
            else
                load(file_loc, 'meas_gam', 'fits_gam')
            end
        end

        if plot_type.boxplots == 1 || plot_type.errorbars == 1
            num_xvs = length(meas_gam.r2s);
            num_neurons = length(meas_gam.r2s{1});
            r2s_temp = NaN(num_neurons, num_xvs);
            for nxv = 1:num_xvs
                r2s_temp(:, nxv) = meas_gam.r2s{nxv};
            end
            r2s{ds, i} = r2s_temp;
        end
        if plot_type.coupling_scatter
            num_xvs = length(meas_gam.r2s);
            num_neurons = length(meas_gam.r2s{1});
            coupling_add = NaN(num_neurons, num_xvs);
            coupling_mul = NaN(num_neurons, num_xvs);
            [temp_lvs, ~, ~, ~, signs] = getGamPredictions( ...
                data_struct, net_arch, fits_gam);
            for nxv = 1:num_xvs
                coupling_add(:, nxv) = signs(nxv, 2) * ...
                    fits_gam{nxv}.add_subunits(2).layers(end).weights;
                coupling_mul(:, nxv) = signs(nxv, 1) * ...
                    fits_gam{nxv}.add_subunits(1).layers(end).weights;
            end
            coupling{ds, 1} = coupling_add;
            coupling{ds, 2} = coupling_mul;
        end
        if plot_type.lvs_scatter
            temp_lvs = getGamPredictions(data_struct, net_arch, fits_gam);
            lvs{ds, 1} = temp_lvs(:, 1);
            lvs{ds, 2} = temp_lvs(:, 2);
        end
        if plot_type.coupling_vs_pref
            num_xvs = length(meas_gam.r2s);
            num_neurons = length(meas_gam.r2s{1});
            coupling_add = NaN(num_neurons, num_xvs);
            coupling_mul = NaN(num_neurons, num_xvs);
            for nxv = 1:num_xvs
                coupling_add(:, nxv) = ...
                    fits_gam{nxv}.add_subunits(2).layers(end).weights;
                coupling_mul(:, nxv) = ...
                    fits_gam{nxv}.add_subunits(1).layers(end).weights;
            end
            coupling{ds, 1} = coupling_add;
            coupling{ds, 2} = coupling_mul;
            [osi{ds}, ori_pref{ds}, dsi{ds}, dir_pref{ds}] = ...
                calcTuningMeasures(dataset_strs{ds});
        end
        
    end % num_models
end % num_datasets

%% plot

b = [     0    0.4470    0.7410]; % 0 114 189
r = [0.8500    0.3250    0.0980]; % 217 83 25
y = [0.9290    0.6940    0.1250]; % 237 177 32
p = [0.4940    0.1840    0.5560]; % 126 47 142
g = [0.4660    0.6740    0.1880]; % 119 172 48

if new_fig; figure; else hold on; end

% tidy up model strings
assign_line_properties;
      
pvals = cell(num_datasets, 1);
pvals_nonpar = cell(num_datasets, 1);
for ds = 1:num_datasets

    subplot(num_datasets, 1, ds);

    if plot_type.boxplots == 1 || plot_type.errorbars == 1
        vals = cell(num_models, 1);
        for i = 1:num_models
            vals{i} = [];
        end        

        for i = 1:num_models
            if datasets(ds) < 100
                vals{i} = [vals{i}, median(r2s{ds, i}, 1)];
            else
                vals{i} = [vals{i}, mean(r2s{ds, i}, 1)]; % avg r2s over neurons
            end
        end
    end

    if plot_type.boxplots == 1
        vals_mat = NaN(length(vals{1}), num_models);
        legend_str = {};
        colors = [];
        for i = 1:num_models
            vals_mat(:, i) = (vals{i}(:) - vals{1}(:)) ./ ...
                (1 - vals{1}(:));
%             vals_mat(:, i) = vals{i}(:);
            legend_str = [legend_str, model_strs2{i}];
            colors = [colors; model_colors{i}];
        end

        % calculate p-values
        pvals{ds} = NaN(num_models);
        %pvals_nonpar{ds} = NaN(num_models);
        for i = 2:num_models
            for k = 1:(i-1)
                [~, pvals{ds}(i, k)] = ...
                    ttest(vals_mat(:, i), vals_mat(:, k));
                %pvals_nonpar{m, ds}(i, j) = ...
                %    signrank(vals_mat(:, i), vals_mat(:, j));
            end
        end

        % --- plot d2
        if size(vals_mat, 2) < 20
            plotstyle = 'traditional';
        else
            plotstyle = 'compact';
        end

        if ds == num_datasets
            h = boxplot(vals_mat, ...
                'labels', legend_str, ...
                'labelorientation', 'inline', ...
                'colors', colors, ...
                'plotstyle', plotstyle);        
            set(h, 'LineWidth', 1)
        else
            h = boxplot(vals_mat, ...
                'labelorientation', 'inline', ...
                'colors', colors, ...
                'plotstyle', plotstyle);        
            set(h, 'LineWidth', 1)
        end
        ylabel('R^2')
    end
    
    if plot_type.errorbars == 1
        vals_mat = NaN(length(vals{1}), num_models);
        legend_str = {};
        colors = [];
        for i = 1:num_models
            vals_mat(:, i) = vals{i}(:);
%             vals_mat(:, i) = ...
%                 (vals{i}(:) - vals{1}(:)) ./ ...
%                 (1 - vals{1}(:));
            legend_str = [legend_str, model_strs2{i}];
            colors = [colors; model_colors{i}];
        end
        
        % --- plot d2
        means = mean(vals_mat, 1);
        stds = std(vals_mat, [], 1) / sqrt(size(vals_mat, 1));
        
        idx = num_models / 2;
        errorbar(means(1:idx), stds(1:idx))
        hold on
        errorbar(means(idx+1:end), stds(idx+1:end))

%         errorbar(means(1:8), stds(1:8))
%         hold on
%         errorbar(means(9:16), stds(9:16))
%         errorbar(means(17:24), stds(17:24))
        
        %ylabel('R^2')
        ylabel('QI')
    end

    if plot_type.coupling_scatter
        if plot_type.coupling_scatter == 1
            x = mean(coupling{ds, 1}, 2);
            y = mean(coupling{ds, 2}, 2);
            plot(x, y, '.')
        elseif plot_type.coupling_scatter == 2
            x = coupling{ds, 1}(:);
            y = coupling{ds, 2}(:);
            for nxv = 1:1
                plot(coupling{ds, 1}(:, nxv), coupling{ds, 2}(:, nxv), '.')
                hold on;
            end
        elseif plot_type.coupling_scatter == 3
            % combine all neurons
            if ds == 1
%                 x = mean(coupling{ds, 1}, 2);
%                 y = mean(coupling{ds, 2}, 2);
                x = coupling{ds, 1}(:);
                y = coupling{ds, 2}(:);
            else
%                 x = [x; mean(coupling{ds, 1}, 2)];
%                 y = [y; mean(coupling{ds, 2}, 2)];
                x = [x; coupling{ds, 1}(:)];
                y = [y; coupling{ds, 2}(:)];
            end
            if ds == num_datasets
                plot(x, y, '.')
            end
        end
        % calculate and plot linear regression
        n = sum(~isnan(x));
        lm = fitlm(x, y);
        ax_fac = 1.05;
        xmin = floor(min(x) / ax_fac) * ax_fac; 
        xmax = ceil(max(x) / ax_fac) * ax_fac;

        line([xmin, xmax], ...
             [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
              lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
             'color', 'k')
        xlim([xmin, xmax])
        text(0.95, 0.95, ...
             sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                     lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
     
        xlabel('Add')
        ylabel('Mul')
    end
    
    if plot_type.lvs_scatter
        if plot_type.lvs_scatter == 1
            x = lvs{ds, 1};
            y = lvs{ds, 2};
            plot(x, y, '.')
        elseif plot_type.lvs_scatter == 2
            % combine all neurons
            if ds == 1
                x = lvs{ds, 1}(:);
                y = lvs{ds, 2}(:);
            else
                x = [x; lvs{ds, 1}(:)];
                y = [y; lvs{ds, 2}(:)];
            end
            if ds == num_datasets
                subplot(1, 1, 1);
                plot(x, y, '.')
            end
        end
        % calculate and plot linear regression
        n = sum(~isnan(x));
        lm = fitlm(x, y);
        ax_fac = 1.05;
        xmin = floor(min(x) / ax_fac) * ax_fac; 
        xmax = ceil(max(x) / ax_fac) * ax_fac;

        line([xmin, xmax], ...
             [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
              lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
             'color', 'k')
        xlim([xmin, xmax])
        text(0.95, 0.95, ...
             sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                     lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
     
        xlabel('Add')
        ylabel('Mul')
    end
    
    if plot_type.coupling_vs_pref
        if plot_type.coupling_vs_pref == 1
            
            type = 1; % 1 for ori/dir pref on x-axis, 2 for osi/dsi
            
            x1 = osi{ds}(:); osi_thresh = 0.05;
            x2 = dsi{ds}(:); dsi_thresh = 0.05;
            x3 = ori_pref{ds}(:);
            x4 = dir_pref{ds}(:);
%             y1 = coupling{ds, 1}(:, 2); %mean(coupling{ds, 1}, 2);
%             y2 = coupling{ds, 2}(:, 2); %mean(coupling{ds, 2}, 2);
            y1 = mean(coupling{ds, 1}, 2);
            y2 = mean(coupling{ds, 2}, 2);
            
            num_cols = 4;
            
            subplot(num_datasets, num_cols, (ds - 1) * num_cols + 1);
            if type == 1
                x = x3(x1 > osi_thresh);
                y = y2(x1 > osi_thresh);
                plot(x, y, '.')
                xlabel('ori_pref')
                ylabel('mult coupling')
            else
                x = x1;
                y = y2;
                plot(x, y, '.')
                xlabel('osi')
                ylabel('mult coupling')
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
            xmin = floor(min(x) / ax_fac) * ax_fac; 
            xmax = ceil(max(x) / ax_fac) * ax_fac;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                         lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            
            subplot(num_datasets, num_cols, (ds - 1) * num_cols + 2);
            if type == 1
                x = x3(x1 > osi_thresh);
                y = y1(x1 > osi_thresh);
                plot(x, y, '.')
                xlabel('ori_pref')
                ylabel('add coupling')
            else
                x = x1;
                y = y1;
                plot(x, y, '.')
                xlabel('osi')
                ylabel('add coupling')
            end
            
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
            xmin = floor(min(x) / ax_fac) * ax_fac; 
            xmax = ceil(max(x) / ax_fac) * ax_fac;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                         lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
             
            subplot(num_datasets, num_cols, (ds - 1) * num_cols + 3);
            if type == 1
                x = x4(x2 > dsi_thresh);
                y = y2(x2 > dsi_thresh);
                plot(x, y, '.')
                xlabel('dir_pref')
                ylabel('mult coupling')
            else
                x = x2;
                y = y2;
                plot(x, y, '.')
                xlabel('dsi')
                ylabel('mult coupling')
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
            xmin = floor(min(x) / ax_fac) * ax_fac; 
            xmax = ceil(max(x) / ax_fac) * ax_fac;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                         lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
             
            subplot(num_datasets, num_cols, (ds - 1) * num_cols + 4);
            if type == 1
                x = x4(x2 > dsi_thresh);
                y = y1(x2 > dsi_thresh);
                plot(x, y, '.')
                xlabel('dir_pref')
                ylabel('add coupling')
            else
                x = x2;
                y = y1;
                plot(x, y, '.')
                xlabel('dsi')
                ylabel('add coupling')
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
            xmin = floor(min(x) / ax_fac) * ax_fac; 
            xmax = ceil(max(x) / ax_fac) * ax_fac;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('m = %1.2f\np = %1.2g\nN = %i', ...
                         lm.Coefficients{2, 1}, lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
             
        elseif plot_type.coupling_vs_pref == 2
            % combine all neurons
            if ds == 1
%                 x = mean(coupling{ds, 1}, 2);
%                 y = mean(coupling{ds, 2}, 2);
                x = coupling{ds, 1}(:);
                y = coupling{ds, 2}(:);
            else
%                 x = [x; mean(coupling{ds, 1}, 2)];
%                 y = [y; mean(coupling{ds, 2}, 2)];
                x = [x; coupling{ds, 1}(:)];
                y = [y; coupling{ds, 2}(:)];
            end
            if ds == num_datasets
                plot(x, y, '.')
            end
        end

    end
    
    
    % clean up plots
%         if length(datasets) > 1
%             title(sprintf('datasets %s - %s', datasets{1}, datasets{end}))
%         else
%             title(sprintf('%s', datasets{1}))
%         end
    
    set(gca, 'FontSize', fontsize)
    set(gca, 'XColor', 'k')
    set(gca, 'YColor', 'k')
    box off
    legend boxoff
%         axis square

end
