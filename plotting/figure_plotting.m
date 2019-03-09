% user variables

datasets = [1, 2, 3]; % v1
% datasets = [11, 12, 13]; % pfc

model_dir = '';
num_folds = 5;
num_xvs = 5;
num_datasets = length(datasets);

% choose plot type
plot_type.model_scatter = 0;    % r2 scatter plots
plot_type.extended_aff = 0;     % QI of extended affine model
plot_type.nonlinear_comp = 1;   % compare QIs of various nonlinear models
                                % RLVM/SRLVM, affine, best extended affine
plot_type.nonlinear_comp2 = 0;  % RLVM/SRLVM, all GAMs

% initialize variables
if plot_type.model_scatter
    plot_scatter = 1; % 0 to plot qi diff hists instead of scatter
    model_strs = { ...
        'ind', ...
        'add-pop_01', 'goris-pop', 'mult-pop_01', ...
        'lin-pop', 'aff-pop_01_01', ...
        'add_10-02', 'add_10-04', ...
    };
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.extended_aff
    model_strs = { ...
        'ind', 'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', ...
        'mult-pop_01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', ...
        'mult-pop_02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', ...
        'mult-pop_03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', ...
        'mult-pop_04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', ...
    };
    add_rows = 5;
    mul_rows = 5;
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.nonlinear_comp
    if datasets(1) < 10
        % V1 data
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_03_03', ... % best model for mk 1
            'aff-pop_02_02', ... % best model for mk 2
            'aff-pop_04_04', ... % best model for mk 3
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', ... % rlvms
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', ... % srlvms
        };
        num_models = length(model_strs);
        num_bfs = 4;
    elseif datasets(1) > 10
        % PFC data
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_04_04', ... % best model for mk 1
            'aff-pop_04_04', ... % best model for mk 2
            'aff-pop_04_04', ... % best model for mk 3
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', ... % rlvms
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', ... % srlvms
        };
        num_models = length(model_strs);
        num_bfs = 4;
    end
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.nonlinear_comp2
    model_strs = { ...
        'ind', ...
        'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', ...
        'mult-pop_01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', ...
        'mult-pop_02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', ...
        'mult-pop_03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', ...
        'mult-pop_04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', ...
        'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', ... % srlvms
    };
    add_rows = 5;
    mul_rows = 5;
    num_bfs = 4;
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end

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
        if plot_type.model_scatter
            r2s{ds, i} = mean(r2s_temp, 2); % avg over xvs
        else
            r2s{ds, i} = r2s_temp;
        end
        
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
fontsize = 8;

qi_all = cell(num_models, 1);

for ds = 1:num_datasets
        
    if plot_type.model_scatter
    
        % --- plot r2s
        num_cols = 6;
        all_expts = 1;    % 1 to append a row for all expts combined
        % plot_scatter = 0; % 0 to plot qi diff hists instead of scatter
        num_bins = 30;    % histogram bins
        if all_expts == 1
            off = 1;
        else
            off = 0;
        end
        if plot_scatter
            xmin = 0; xmax = 0.7; ymin = 0; ymax = 0.7;
        else
            xmin = -0.05; xmax = 0.12;
        end
        
        idx.ind = 1;
        idx.add = 2;
        idx.gor = 3;
        idx.mul = 4;
        idx.lin = 5;
        idx.aff = 6;
        idx.srlvm2 = 7;
        idx.srlvm4 = 8;
        
        % extended mult vs goris
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 1);
        x = (r2s{ds, idx.gor} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.gor} = [qi_all{idx.gor}; x(:)];
        y = (r2s{ds, idx.mul} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.mul} = [qi_all{idx.mul}; y(:)];
        x_model = 'Constrained Mult';
        y_model = 'Multiplicative';
        model_scatter_plot_helper
        
        % aff vs lin
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 2);
        x = (r2s{ds, idx.lin} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.lin} = [qi_all{idx.lin}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        x_model = 'Constrained Affine';
        y_model = 'Affine';
        model_scatter_plot_helper
        
        % aff vs extended add
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 3);
        x = (r2s{ds, idx.add} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.add} = [qi_all{idx.add}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        x_model = 'Additive';
        y_model = 'Affine';
        model_scatter_plot_helper
        
        % aff vs extended mult
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 4);
        x = (r2s{ds, idx.mul} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.mul} = [qi_all{idx.mul}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        x_model = 'Multiplicative';
        y_model = 'Affine';
        model_scatter_plot_helper
        
        % aff vs srlvm-2
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 5);
        x = (r2s{ds, idx.srlvm2} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.srlvm2} = [qi_all{idx.srlvm2}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        x_model = 'SRLVM-2';
        y_model = 'Affine';
        model_scatter_plot_helper
        
        % aff vs srlvm-4
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 6);
        x = (r2s{ds, idx.srlvm4} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.srlvm4} = [qi_all{idx.srlvm4}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        x_model = 'SRLVM-4';
        y_model = 'Affine';
        model_scatter_plot_helper
        
        if ds == num_datasets && all_expts == 1
            
            % extended mult vs goris
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 1);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.gor} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.mul} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.gor} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.mul} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'Constrained Mult';
            y_model = 'Multiplicative';
            model_scatter_all_plot_helper
            
            % aff vs lin
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 2);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.lin} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.lin} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'Constrained Affine';
            y_model = 'Affine';
            model_scatter_all_plot_helper
            
            % aff vs extended add
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 3);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.add} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.add} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'Additive';
            y_model = 'Affine';
            model_scatter_all_plot_helper
            
            % aff vs extended mult
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 4);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.mul} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.mul} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'Multiplicative';
            y_model = 'Affine';
            model_scatter_all_plot_helper
            
            % aff vs srlvm-2
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 5);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.srlvm2} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.srlvm2} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'SRLVM-2';
            y_model = 'Affine';
            model_scatter_all_plot_helper
            
            % aff vs srlvm-4
            subplot(num_datasets + 1, num_cols, (ds) * num_cols + 6);
            x = []; y = [];
            for dss = 1:num_datasets
                if plot_scatter
                    x = (r2s{dss, idx.srlvm4} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    y = (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind});
                    plot(x, y, '.');
                else
                    x = [x; (r2s{dss, idx.srlvm4} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                    y = [y; (r2s{dss, idx.aff} - r2s{dss, idx.ind}) ./ ...
                        (1 - r2s{dss, idx.ind})];
                end
                hold on
            end
            x_model = 'SRLVM-4';
            y_model = 'Affine';
            model_scatter_all_plot_helper
            
        end
        
    end
    
    if plot_type.extended_aff
        
        % avg r2s over neurons
        vals = cell(num_models, 1);
        for i = 1:num_models
            vals{i} = mean(r2s{ds, i}, 2); 
        end
        
        % calculate qi
        for i = 1:num_models
            qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
        end
        
        % average qi over xv folds
        vals_mat = NaN(num_models, 1);
        for i = 1:num_models
            vals_mat(i) = mean(qi_all{i});
        end

        % plot
        vals_mat = reshape(vals_mat, add_rows, mul_rows);
        vals_mat(1, 1) = NaN; % don't plot zeroed out stim model
        subplot(num_datasets, 1, ds)
        imagesc(vals_mat);
        set(gca, 'ydir', 'normal')
        set(gca, 'xticklabel', 0:mul_rows-1)
        set(gca, 'yticklabel', 0:add_rows-1)
        ylabel('Additive LVs')
        xlabel('Multiplicative LVs')
        colormap(hot)
        colorbar
        
    end
    
    if plot_type.nonlinear_comp
        
        subplot(num_datasets, 1, ds)
        vals = cell(num_models, 1);
        vals2 = cell(num_models, 1);
        for i = 1:num_models
            vals{i} = mean(r2s{ds, i}, 1); % avg r2s over neurons
            vals2{i} = mean(r2s{ds, i}, 2);
        end
        vals_mat = NaN(length(vals{1}), num_models);
        for i = 1:num_models
            vals_mat(:, i) = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
            qi_all{i} = (vals2{i}(:) - vals2{1}(:)) ./ (1 - vals2{1}(:));
        end
        
        means = mean(vals_mat, 1);
        stds = std(vals_mat, [], 1) / sqrt(size(vals_mat, 1));
        % plot rlvms
        base_indx = num_datasets + 2;
        indxs = base_indx + 1: base_indx + num_bfs;
        errorbar(means(indxs), stds(indxs))
        hold on
        % plot srlvms
        base_indx = num_datasets + 2 + num_bfs;
        indxs = base_indx + 1: base_indx + num_bfs;
        errorbar(means(indxs), stds(indxs))
        % plot affine model
        base_indx = num_datasets + 1;
        errorbar( ...
            repmat(means(base_indx + 1), num_bfs), ...
            repmat(stds(base_indx + 1), num_bfs));
        % plot best extended affine model
        base_indx = 1;
        errorbar( ...
            repmat(means(base_indx + ds), num_bfs), ...
            repmat(stds(base_indx + ds), num_bfs));
        ylabel('Quality Index')
        xlabel('Number of LVs')
        
    end

    if plot_type.nonlinear_comp2
        
        vals = cell(num_models, 1);
        for i = 1:num_models
            vals{i} = mean(r2s{ds, i}, 1); % avg r2s over neurons
        end
        for i = 1:num_models
            qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
        end
        vals_mat = NaN(num_models, 1);
        vals_mat2 = NaN(num_xvs, num_models);
        for i = 1:num_models
            vals_mat(i) = mean(qi_all{i}); % mean qi over xv folds
            vals_mat2(:, i) = qi_all{i}(:);
        end
        
        % plot
        means = mean(vals_mat2, 1);
        stds = std(vals_mat2, [], 1) / sqrt(size(vals_mat2, 1));

        % just plot average
        vals_mat1 = vals_mat(1:add_rows*mul_rows);
        vals_mat1(1) = NaN; % don't plot zeroed out stim model
        num_lvs = (1:length(vals_mat1)) - 1;
        num_lvs = floor(num_lvs / add_rows) + repmat(0:add_rows-1, 1, mul_rows);
        
        subplot(num_datasets, 1, ds)
        
        % plot gams
        scatter( ...
            num_lvs + 0.15 * (rand(size(num_lvs)) - 0.5), ...
            vals_mat1 + 0.015 * (rand(size(vals_mat1)) - 0.5), ...
            '.')
        hold on;
        
        % plot srlvms
        indxs = (add_rows * mul_rows + 1) : num_models;
        errorbar(means(indxs)', stds(indxs)')
        
        ylabel('QI')
        xlabel('Number of LVs')
    end

    clean_plot

end
