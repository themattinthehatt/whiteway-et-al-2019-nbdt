% user variables
model_dir = '';

datasets = [1, 2, 3]; % v1
% datasets = [11, 12, 13];

num_folds = 5;
num_xvs = 5;
num_datasets = length(datasets);
new_fig = 1;

% choose plot type
plot_type.aff_increase = 0;     % stim r2 vs aff improve r2 scatter/hists
plot_type.aff_increase_nc = 0;  % scatter of noise corrs vs  aff improve r2
plot_type.model_scatter = 1;    % r2 scatter plots
plot_type.model_compare = 0;    % true-pred fr for each model across trials
plot_type.coupling_vs_pref = 0; % coupling versus ori/dir preference
plot_type.coup_lvs_scatter = 0; % scatter of add/mult weights in aff models
plot_type.lgn_boxplots = 0;     % QI of lv vs other preds in boxplot form                           
plot_type.extended_aff = 0;     % QI of extended affine model
plot_type.nonlinear_comp = 0;   % compare QIs of various nonlinear models
                                % RLVM/SRLVM, affine, best extended affine
plot_type.nonlinear_comp2 = 0;  % RLVM/SRLVM, all GAMs
                                
plot_type.boxplots = 0;         % model performance (r2) in boxplot form
plot_type.errorbars = 0;        % model performance (r2) in errorbar form

% initialize variables
if plot_type.aff_increase
    if datasets(1) < 102
        if isempty(model_dir)
%             model_strs = {'ind', 'aff-pop_00-01_00-01'};
            model_strs = {'ind', 'add_10-01'};
        else
            model_strs = {'ind', 'aff-pop_01_01'};
        end
    elseif datasets(1) > 130
        model_strs = {'ind', 'aff-pop_01_01'};
    else
%         model_strs = {'ind', 'aff-pop_01_oneplus'};
        model_strs = {'ind', 'aff-pop_01_01'};
    end
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
    rhos = NaN(num_datasets, 1);
end
if plot_type.aff_increase_nc
    model_strs = {'ind', 'aff-pop_01_01', 'aff-pop_00-01_00-01'};
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
    rhos = NaN(num_datasets, 1);
end
if plot_type.model_scatter
%     model_strs = {'ind', ...
%         'add-pop_01', ...
%         'goris-pop_oneplus', 'mult-pop_01_oneplus', ...
%         'lin-pop_oneplus', 'aff-pop_01_oneplus', ...
%         };
%     model_strs = {'ind', ...
%         'add-pop_00-01', ...
%         'goris-pop', 'mult-pop_00-01', ...
%         'lin-pop', 'aff-pop_01_01', ...
%         };
%     model_strs = {'ind', ...
%         'add-pop_01', ...
%         'goris-pop', 'mult-pop_01', ...
%         'lin-pop', 'aff-pop_00-01_00-01', ...
%         };
    model_strs = {'ind', ...
        'add_04', ...
        'goris-pop', 'add_04', ...
        'lin-pop', 'aff-pop_01_01', ...
        };
%     model_strs = {'ind', 'add_04'};
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.model_compare
    model_strs = {'ind', 'add_04'};
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
    datas = cell(num_datasets, 1);
    pred = cell(num_datasets, num_models);
end
if plot_type.coupling_vs_pref == 1
    %model_strs = {'aff-pop_01_oneplus'};
    model_strs = {'aff-pop_01_01'};
    num_models = 1;
    sub_dir = '';
    custom_ext = '';
    ori_pref = cell(num_datasets, 1);
    dir_pref = cell(num_datasets, 1);
    osi = cell(num_datasets, 1);
    dsi = cell(num_datasets, 1);
    coupling = cell(num_datasets, 2);
end
if plot_type.coup_lvs_scatter == 1
    %model_strs = {'aff-pop_01_oneplus'};
    model_strs = {'aff-pop_01_01'};
    num_models = 1;
    sub_dir = '';
    custom_ext = '';
    coupling = cell(num_datasets, 2);
    lvs = cell(num_datasets, 2);
end
if plot_type.lgn_boxplots
    model_strs = {'ind', ...
        'add-pop_01', 'add-popavg', 'add-pup', 'add-run', ...
        'mult-pop_01_oneplus', 'mult-popavg_oneplus', 'mult-pup_oneplus', 'mult-run_oneplus', ...
        'aff-pop_01_oneplus', 'aff-popavg_oneplus', 'aff-pup_oneplus', 'aff-pup_oneplus', ...
    };
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.extended_aff
    if datasets(1) == 101 || datasets(1) == 111 || datasets(1) == 121
        % v1 - 500 ms linear
        model_strs = { ...
            'ind', 'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', ...
            'mult-pop_01_oneplus', 'aff-pop_00-01_00-01', 'aff-pop_00-02_00-01', 'aff-pop_00-03_00-01', 'aff-pop_00-04_00-01', 'aff-pop_00-05_00-01', ...
            'mult-pop_02_oneplus', 'aff-pop_00-01_00-02', 'aff-pop_00-02_00-02', 'aff-pop_00-03_00-02', 'aff-pop_00-04_00-02', 'aff-pop_00-05_00-02', ...
            'mult-pop_03_oneplus', 'aff-pop_00-01_00-03', 'aff-pop_00-02_00-03', 'aff-pop_00-03_00-03', 'aff-pop_00-04_00-03', 'aff-pop_00-05_00-03', ...
            'mult-pop_04_oneplus', 'aff-pop_00-01_00-04', 'aff-pop_00-02_00-04', 'aff-pop_00-03_00-04', 'aff-pop_00-04_00-04', 'aff-pop_00-05_00-04', ...
            'mult-pop_05_oneplus', 'aff-pop_00-01_00-05', 'aff-pop_00-02_00-05', 'aff-pop_00-03_00-05', 'aff-pop_00-04_00-05', 'aff-pop_00-05_00-05', ...
            };
%         % v1 - 500 ms nonlinear
%         model_strs = { ...
%             'ind', 'add-pop_10-01', 'add-pop_10-02', 'add-pop_10-03', 'add-pop_10-04', 'add-pop_10-05', ...
%             'mult-pop_10-01', 'aff-pop_10-01_10-01', 'aff-pop_10-02_10-01', 'aff-pop_10-03_10-01', 'aff-pop_10-04_10-01', 'aff-pop_10-05_10-01', ...
%             'mult-pop_10-02', 'aff-pop_10-01_10-02', 'aff-pop_10-02_10-02', 'aff-pop_10-03_10-02', 'aff-pop_10-04_10-02', 'aff-pop_10-05_10-02', ...
%             'mult-pop_10-03', 'aff-pop_10-01_10-03', 'aff-pop_10-02_10-03', 'aff-pop_10-03_10-03', 'aff-pop_10-04_10-03', 'aff-pop_10-05_10-03', ...
%             'mult-pop_10-04', 'aff-pop_10-01_10-04', 'aff-pop_10-02_10-04', 'aff-pop_10-03_10-04', 'aff-pop_10-04_10-04', 'aff-pop_10-05_10-04', ...
%             'mult-pop_10-05', 'aff-pop_10-01_10-05', 'aff-pop_10-02_10-05', 'aff-pop_10-03_10-05', 'aff-pop_10-04_10-05', 'aff-pop_10-05_10-05', ...
%             };
        add_rows = 6;
        mul_rows = 6;
    elseif datasets(1) > 20 && datasets(1) < 25
        % lgn w/o blank stims
        if isempty(model_dir)
            model_strs = { ...
                    'ind', 'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', 'add-pop_06', 'add-pop_07', ...
                    'mult-pop_01', 'aff-pop_00-01_00-01', 'aff-pop_00-02_00-01', 'aff-pop_00-03_00-01', 'aff-pop_00-04_00-01', 'aff-pop_00-05_00-01', 'aff-pop_00-06_00-01', 'aff-pop_00-07_00-01', ...
                    'mult-pop_02', 'aff-pop_00-01_00-02', 'aff-pop_00-02_00-02', 'aff-pop_00-03_00-02', 'aff-pop_00-04_00-02', 'aff-pop_00-05_00-02', 'aff-pop_00-06_00-02', 'aff-pop_00-07_00-02', ...
                    'mult-pop_03', 'aff-pop_00-01_00-03', 'aff-pop_00-02_00-03', 'aff-pop_00-03_00-03', 'aff-pop_00-04_00-03', 'aff-pop_00-05_00-03', 'aff-pop_00-06_00-03', 'aff-pop_00-07_00-03', ...
                    'mult-pop_04', 'aff-pop_00-01_00-04', 'aff-pop_00-02_00-04', 'aff-pop_00-03_00-04', 'aff-pop_00-04_00-04', 'aff-pop_00-05_00-04', 'aff-pop_00-06_00-04', 'aff-pop_00-07_00-04', ...
                    'mult-pop_05', 'aff-pop_00-01_00-05', 'aff-pop_00-02_00-05', 'aff-pop_00-03_00-05', 'aff-pop_00-04_00-05', 'aff-pop_00-05_00-05', 'aff-pop_00-06_00-05', 'aff-pop_00-07_00-05', ...
                    'mult-pop_06', 'aff-pop_00-01_00-06', 'aff-pop_00-02_00-06', 'aff-pop_00-03_00-06', 'aff-pop_00-04_00-06', 'aff-pop_00-05_00-06', 'aff-pop_00-06_00-06', 'aff-pop_00-07_00-06', ...
                    'mult-pop_07', 'aff-pop_00-01_00-07', 'aff-pop_00-02_00-07', 'aff-pop_00-03_00-07', 'aff-pop_00-04_00-07', 'aff-pop_00-05_00-07', 'aff-pop_00-06_00-07', 'aff-pop_00-07_00-07', ...
                    };
        else
            model_strs = { ...
                'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', 'add-pop_00-06', 'add-pop_00-07', ...
                'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', 'aff-pop_06_01', 'aff-pop_07_01', ...
                'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', 'aff-pop_06_02', 'aff-pop_07_02', ...
                'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', 'aff-pop_06_03', 'aff-pop_07_03', ...
                'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', 'aff-pop_06_04', 'aff-pop_07_04', ...
                'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', 'aff-pop_06_05', 'aff-pop_07_05', ...
                'mult-pop_00-06', 'aff-pop_01_06', 'aff-pop_02_06', 'aff-pop_03_06', 'aff-pop_04_06', 'aff-pop_05_06', 'aff-pop_06_06', 'aff-pop_07_06', ...
                'mult-pop_00-07', 'aff-pop_01_07', 'aff-pop_02_07', 'aff-pop_03_07', 'aff-pop_04_07', 'aff-pop_05_07', 'aff-pop_06_07', 'aff-pop_07_07', ...
                };
        end
        add_rows = 8;
        mul_rows = 8;
    elseif datasets(1) >= 300
        % pfc
%         model_strs = { ...
%             'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', ...
%             'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', ...
%             'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', ...
%             'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', ...
%             'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', ...
%             'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', ...
%             };
%         add_rows = 6;
%         mul_rows = 6;
%         model_strs = { ...
%             'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', 'add-pop_00-06', 'add-pop_00-07', ...
%             'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', 'aff-pop_06_01', 'aff-pop_07_01', ...
%             'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', 'aff-pop_06_02', 'aff-pop_07_02', ...
%             'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', 'aff-pop_06_03', 'aff-pop_07_03', ...
%             'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', 'aff-pop_06_04', 'aff-pop_07_04', ...
%             'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', 'aff-pop_06_05', 'aff-pop_07_05', ...
%             'mult-pop_00-06', 'aff-pop_01_06', 'aff-pop_02_06', 'aff-pop_03_06', 'aff-pop_04_06', 'aff-pop_05_06', 'aff-pop_06_06', 'aff-pop_07_06', ...
%             'mult-pop_00-07', 'aff-pop_01_07', 'aff-pop_02_07', 'aff-pop_03_07', 'aff-pop_04_07', 'aff-pop_05_07', 'aff-pop_06_07', 'aff-pop_07_07', ...
%         };
%         add_rows = 8;
%         mul_rows = 8;
        model_strs = { ...
            'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', 'add-pop_00-06', 'add-pop_00-07', 'add-pop_00-08', 'add-pop_00-09', ...
            'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', 'aff-pop_06_01', 'aff-pop_07_01', 'aff-pop_08_01', 'aff-pop_09_01', ...
            'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', 'aff-pop_06_02', 'aff-pop_07_02', 'aff-pop_08_02', 'aff-pop_09_02', ...
            'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', 'aff-pop_06_03', 'aff-pop_07_03', 'aff-pop_08_03', 'aff-pop_09_03', ...
            'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', 'aff-pop_06_04', 'aff-pop_07_04', 'aff-pop_08_04', 'aff-pop_09_04', ...
            'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', 'aff-pop_06_05', 'aff-pop_07_05', 'aff-pop_08_05', 'aff-pop_09_05', ...
            'mult-pop_00-06', 'aff-pop_01_06', 'aff-pop_02_06', 'aff-pop_03_06', 'aff-pop_04_06', 'aff-pop_05_06', 'aff-pop_06_06', 'aff-pop_07_06', 'aff-pop_08_06', 'aff-pop_09_06', ...
            'mult-pop_00-07', 'aff-pop_01_07', 'aff-pop_02_07', 'aff-pop_03_07', 'aff-pop_04_07', 'aff-pop_05_07', 'aff-pop_06_07', 'aff-pop_07_07', 'aff-pop_08_07', 'aff-pop_09_07', ...
            'mult-pop_00-08', 'aff-pop_01_08', 'aff-pop_02_08', 'aff-pop_03_08', 'aff-pop_04_08', 'aff-pop_05_08', 'aff-pop_06_08', 'aff-pop_07_08', 'aff-pop_08_08', 'aff-pop_09_08', ...
            'mult-pop_00-09', 'aff-pop_01_09', 'aff-pop_02_09', 'aff-pop_03_09', 'aff-pop_04_09', 'aff-pop_05_09', 'aff-pop_06_09', 'aff-pop_07_09', 'aff-pop_08_09', 'aff-pop_09_09', ...
        };
        add_rows = 10;
        mul_rows = 10;
    elseif datasets(1) >= 100
        % v1 - 100 ms linear
        model_strs = { ...
            'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', ...
            'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', ...
            'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', ...
            'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', ...
            'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', ...
            'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', ...
            };
        add_rows = 6;
        mul_rows = 6;
    elseif datasets(1) >= 25
        % lgn awake/anest w/o blank stims
        model_strs = { ...
                'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', 'add-pop_00-06', 'add-pop_00-07', ...
                'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', 'aff-pop_06_01', 'aff-pop_07_01', ...
                'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', 'aff-pop_06_02', 'aff-pop_07_02', ...
                'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', 'aff-pop_06_03', 'aff-pop_07_03', ...
                'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', 'aff-pop_06_04', 'aff-pop_07_04', ...
                'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', 'aff-pop_06_05', 'aff-pop_07_05', ...
                'mult-pop_00-06', 'aff-pop_01_06', 'aff-pop_02_06', 'aff-pop_03_06', 'aff-pop_04_06', 'aff-pop_05_06', 'aff-pop_06_06', 'aff-pop_07_06', ...
                'mult-pop_00-07', 'aff-pop_01_07', 'aff-pop_02_07', 'aff-pop_03_07', 'aff-pop_04_07', 'aff-pop_05_07', 'aff-pop_06_07', 'aff-pop_07_07', ...
                };
        add_rows = 8;
        mul_rows = 8;
    else
        % lgn w/o blank stims
        model_strs = { ...
                'ind', 'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', 'add-pop_06', 'add-pop_07', ...
                'mult-pop_01_oneplus', 'aff-pop_00-01_00-01', 'aff-pop_00-02_00-01', 'aff-pop_00-03_00-01', 'aff-pop_00-04_00-01', 'aff-pop_00-05_00-01', 'aff-pop_00-06_00-01', 'aff-pop_00-07_00-01', ...
                'mult-pop_02_oneplus', 'aff-pop_00-01_00-02', 'aff-pop_00-02_00-02', 'aff-pop_00-03_00-02', 'aff-pop_00-04_00-02', 'aff-pop_00-05_00-02', 'aff-pop_00-06_00-02', 'aff-pop_00-07_00-02', ...
                'mult-pop_03_oneplus', 'aff-pop_00-01_00-03', 'aff-pop_00-02_00-03', 'aff-pop_00-03_00-03', 'aff-pop_00-04_00-03', 'aff-pop_00-05_00-03', 'aff-pop_00-06_00-03', 'aff-pop_00-07_00-03', ...
                'mult-pop_04_oneplus', 'aff-pop_00-01_00-04', 'aff-pop_00-02_00-04', 'aff-pop_00-03_00-04', 'aff-pop_00-04_00-04', 'aff-pop_00-05_00-04', 'aff-pop_00-06_00-04', 'aff-pop_00-07_00-04', ...
                'mult-pop_05_oneplus', 'aff-pop_00-01_00-05', 'aff-pop_00-02_00-05', 'aff-pop_00-03_00-05', 'aff-pop_00-04_00-05', 'aff-pop_00-05_00-05', 'aff-pop_00-06_00-05', 'aff-pop_00-07_00-05', ...
                'mult-pop_06_oneplus', 'aff-pop_00-01_00-06', 'aff-pop_00-02_00-06', 'aff-pop_00-03_00-06', 'aff-pop_00-04_00-06', 'aff-pop_00-05_00-06', 'aff-pop_00-06_00-06', 'aff-pop_00-07_00-06', ...
                'mult-pop_07_oneplus', 'aff-pop_00-01_00-07', 'aff-pop_00-02_00-07', 'aff-pop_00-03_00-07', 'aff-pop_00-04_00-07', 'aff-pop_00-05_00-07', 'aff-pop_00-06_00-07', 'aff-pop_00-07_00-07', ...
                };
        add_rows = 8;
        mul_rows = 8;
    end
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.nonlinear_comp
    if datasets(1) < 100
        % awake mouse LGN
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_00-07_00-07', ... % best model for mouse 1
            'aff-pop_00-07_00-05', ... % best model for mouse 2
            'aff-pop_00-07_00-07', ... % best model for mouse 3
            'aff-pop_00-07_00-07', ... % best model for mouse 4
            'aff-pop_00-01_00-01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_06', 'add_07', 'add_08', 'add_09', 'add_10', ...
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', 'add_10-10',...
            };
        num_models = length(model_strs);
        num_bfs = 10;
    elseif datasets(1) == 100
        % anest monkey v1
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_00-01_00-02', ... % best model for mk 1
            'aff-pop_00-01_00-02', ... % best model for mk 2
            'aff-pop_00-03_00-01', ... % best model for mk 3
            'aff-pop_00-01_00-01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_06', 'add_07', 'add_08', ...
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            'add_10-06', 'add_10-07', 'add_10-08', ...
            };
        num_models = length(model_strs);
        num_bfs = 8;
    elseif datasets(1) == 101
        % hi-rez anest monkey v1
%         model_strs = { ...
%             'ind', ... % for QI calculation
%             'aff-pop_03_01', ... % best model for mk 1
%             'aff-pop_02_01', ... % best model for mk 2
%             'aff-pop_02_02', ... % best model for mk 3
%             'aff-pop_01_01', ... % standard affine model
%             'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
%             'add_06', 'add_07', 'add_08', ...
%             'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
%             'add_10-06', 'add_10-07', 'add_10-08', ...
%             };
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_00-03_00-01', ... % best model for mk 1
            'aff-pop_00-02_00-01', ... % best model for mk 2
            'aff-pop_00-02_00-02', ... % best model for mk 3
            'aff-pop_00-01_00-01', ... % standard affine model
            'add-pop_01', 'add-pop_02', 'add-pop_03', 'add-pop_04', 'add-pop_05', ... % rlvms
            'add-pop_10-01', 'add-pop_10-02', 'add-pop_10-03', 'add-pop_10-04', 'add-pop_10-05', ... % srlvms
            };
        num_models = length(model_strs);
        num_bfs = 5;
    elseif datasets(1) == 102
        % monkey v1 60-1260
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_03_01', ... % best model for mk 1
            'aff-pop_02_01', ... % best model for mk 2
            'aff-pop_02_02', ... % best model for mk 3
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            };
        num_models = length(model_strs);
        num_bfs = 5;
    elseif datasets(1) == 200
        % lgn spiking
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_04_01', ... % best model for ms 1
            'aff-pop_02_01', ... % best model for ms 2
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_06', 'add_07', 'add_08', ...
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            'add_10-06', 'add_10-07', 'add_10-08', ...
            };
        num_models = length(model_strs);
        num_bfs = 8;
    elseif datasets(1) == 300
        % lgn spiking
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_09_04', ... % best model for mk 1
            'aff-pop_06_01', ... % best model for mk 2
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_06', 'add_07', 'add_08', 'add_09', ...
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', ...
            };
        num_models = length(model_strs);
        num_bfs = 9;
    elseif datasets(1) == 400 || datasets(1) == 410
        % lgn spiking
        model_strs = { ...
            'ind', ... % for QI calculation
            'aff-pop_09_09', ... % best model for mk 1
            'aff-pop_07_04', ... % best model for mk 2
            'aff-pop_09_09', ... % best model for mk 3
            'aff-pop_01_01', ... % standard affine model
            'add_01', 'add_02', 'add_03', 'add_04', 'add_05', ... % rlvms
            'add_06', 'add_07', 'add_08', 'add_09', 'add_10', ...
            'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
            'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', 'add_10-10', ...
            };
        num_models = length(model_strs);
        num_bfs = 10;
    end
    
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.nonlinear_comp2
    model_strs = { ...
        'ind', 'add-pop_00-01', 'add-pop_00-02', 'add-pop_00-03', 'add-pop_00-04', 'add-pop_00-05', 'add-pop_00-06', 'add-pop_00-07', 'add-pop_00-08', 'add-pop_00-09', ...
        'mult-pop_00-01', 'aff-pop_01_01', 'aff-pop_02_01', 'aff-pop_03_01', 'aff-pop_04_01', 'aff-pop_05_01', 'aff-pop_06_01', 'aff-pop_07_01', 'aff-pop_08_01', 'aff-pop_09_01', ...
        'mult-pop_00-02', 'aff-pop_01_02', 'aff-pop_02_02', 'aff-pop_03_02', 'aff-pop_04_02', 'aff-pop_05_02', 'aff-pop_06_02', 'aff-pop_07_02', 'aff-pop_08_02', 'aff-pop_09_02', ...
        'mult-pop_00-03', 'aff-pop_01_03', 'aff-pop_02_03', 'aff-pop_03_03', 'aff-pop_04_03', 'aff-pop_05_03', 'aff-pop_06_03', 'aff-pop_07_03', 'aff-pop_08_03', 'aff-pop_09_03', ...
        'mult-pop_00-04', 'aff-pop_01_04', 'aff-pop_02_04', 'aff-pop_03_04', 'aff-pop_04_04', 'aff-pop_05_04', 'aff-pop_06_04', 'aff-pop_07_04', 'aff-pop_08_04', 'aff-pop_09_04', ...
        'mult-pop_00-05', 'aff-pop_01_05', 'aff-pop_02_05', 'aff-pop_03_05', 'aff-pop_04_05', 'aff-pop_05_05', 'aff-pop_06_05', 'aff-pop_07_05', 'aff-pop_08_05', 'aff-pop_09_05', ...
        'mult-pop_00-06', 'aff-pop_01_06', 'aff-pop_02_06', 'aff-pop_03_06', 'aff-pop_04_06', 'aff-pop_05_06', 'aff-pop_06_06', 'aff-pop_07_06', 'aff-pop_08_06', 'aff-pop_09_06', ...
        'mult-pop_00-07', 'aff-pop_01_07', 'aff-pop_02_07', 'aff-pop_03_07', 'aff-pop_04_07', 'aff-pop_05_07', 'aff-pop_06_07', 'aff-pop_07_07', 'aff-pop_08_07', 'aff-pop_09_07', ...
        'mult-pop_00-08', 'aff-pop_01_08', 'aff-pop_02_08', 'aff-pop_03_08', 'aff-pop_04_08', 'aff-pop_05_08', 'aff-pop_06_08', 'aff-pop_07_08', 'aff-pop_08_08', 'aff-pop_09_08', ...
        'mult-pop_00-09', 'aff-pop_01_09', 'aff-pop_02_09', 'aff-pop_03_09', 'aff-pop_04_09', 'aff-pop_05_09', 'aff-pop_06_09', 'aff-pop_07_09', 'aff-pop_08_09', 'aff-pop_09_09', ...
        'add_10-01', 'add_10-02', 'add_10-03', 'add_10-04', 'add_10-05', ... % srlvms
        'add_10-06', 'add_10-07', 'add_10-08', 'add_10-09', 'add_10-10', ...
    };
    add_rows = 10;
    mul_rows = 10;
    num_bfs = 10;
    num_models = length(model_strs);
    sub_dir = '';
    custom_ext = '';
    r2s = cell(num_datasets, num_models);
end
if plot_type.boxplots == 1 || plot_type.errorbars == 1
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
            % only load what is necessary
            if plot_type.boxplots || plot_type.errorbars || ...
                    plot_type.model_scatter || plot_type.lgn_boxplots || ...
                    plot_type.extended_aff || plot_type.nonlinear_comp || ...
                    plot_type.aff_increase || plot_type.nonlinear_comp2
                load(file_loc, 'meas_gam')
            elseif plot_type.coup_lvs_scatter || plot_type.model_compare
                load(file_loc, ...
                    'meas_gam', 'fits_gam', 'net_arch', 'data_struct', ...
                    'net_io')
            else
                load(file_loc, 'meas_gam', 'fits_gam')
            end
        end

        if plot_type.boxplots || plot_type.errorbars || ...
                plot_type.model_scatter || plot_type.lgn_boxplots || ...
                plot_type.extended_aff || plot_type.nonlinear_comp || ...
                plot_type.aff_increase || plot_type.model_compare || ...
                plot_type.nonlinear_comp2
            num_xvs = length(meas_gam.r2s);
            num_neurons = length(meas_gam.r2s{1});
            r2s_temp = NaN(num_neurons, num_xvs);
            for nxv = 1:num_xvs
                r2s_temp(:, nxv) = meas_gam.r2s{nxv};
            end
            if plot_type.model_scatter
                if datasets(ds) < 100
                    r2s{ds, i} = median(r2s_temp, 2); % avg over xvs
                else
                    r2s{ds, i} = mean(r2s_temp, 2); % avg over xvs
                end
            else
                r2s{ds, i} = r2s_temp;
            end
            
        end
        if plot_type.coup_lvs_scatter
            num_xvs = length(meas_gam.r2s);
            num_neurons = length(meas_gam.r2s{1});
            coupling_add = NaN(num_neurons, num_xvs);
            coupling_mul = NaN(num_neurons, num_xvs);
            [temp_lvs, ~, ~, ~, signs] = getGamPredictions( ...
                data_struct, net_arch, fits_gam, net_io);
            for nxv = 1:num_xvs
                coupling_add(:, nxv) = ...signs(nxv, 2) * ...
                    fits_gam{nxv}.add_subunits(2).layers(end).weights;
                coupling_mul(:, nxv) = ...signs(nxv, 1) * ...
                    fits_gam{nxv}.add_subunits(1).layers(end).weights;
            end
            if ds == 2
                signn = -1;
            else
                signn = 1;
            end
%             coupling{ds, 1} = signn * coupling_add;
%             coupling{ds, 2} = coupling_mul;
%             lvs{ds, 1} = signn * temp_lvs(:, 1);
%             lvs{ds, 2} = temp_lvs(:, 2);
            coupling{ds, 1} = coupling_add;
            coupling{ds, 2} = coupling_mul;
            lvs{ds, 1} = temp_lvs{1};
            lvs{ds, 2} = temp_lvs{2};
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
        if plot_type.model_compare
            % load data
            [expt_struct, data, trial_ids, ~, ~] = ...
                loadData(dataset);
            datas{ds} = normalizeData(dataset, data);
            pred{ds, i} = getGamPredictions( ...
                data_struct, net_arch, fits_gam, net_io, 0);            
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
fontsize = 8;
      
pvals = cell(num_datasets, 1);
pvals_nonpar = cell(num_datasets, 1);
qi_all = cell(num_models, 1);
for m = 1:num_models
    qi_all{m} = [];
end
qi_all2 = qi_all;
osi_all = [];
dsi_all = [];
opr_all = [];
dpr_all = [];
add_all = [];
mul_all = [];
lvs_all{1} = [];
lvs_all{2} = [];
plot_type.extended_aff2 = 0;
for ds = 1:num_datasets

    if plot_type.aff_increase
     % --- plot r2s
        num_cols = 3;
        all_expts = 1;
        if all_expts == 1 && num_datasets > 1
            off = 1;
        else
            off = 0;
        end
        
%         xmin = 0; xmax = 1.0; ymin = 0; ymax = 1.0;
%         if datasets(1) < 100
%             xmin = -2; xmax = 2; ymin = -2; ymax = 2;
%         else
            xmin = -0.25; xmax = 1; ymin = -0.25; ymax = 1;
%         end
        num_bins = 15;
        
        % extended aff vs ind
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 1);
        set(gca, 'fontname', 'times')
        x = mean(r2s{ds, 1}, 2);
        y = (mean(r2s{ds, 2}, 2) - mean(r2s{ds, 1}, 2)); % ./ ...
%             (1.0 - mean(r2s{ds, 1}, 2));
        qi_all{1} = [qi_all{1}; x(:)];
        qi_all{2} = [qi_all{2}; y(:)];
        plot(x, y, '.k');
        xlabel('R^2_{ind}', 'interpreter', 'tex')
        ylabel('R^2_{affine} - R^2_{ind}', ...
            'interpreter', 'tex')
        xlim([xmin, xmax])
        ylim([ymin, ymax])
        % draw line
        line([xmin, xmax], [ymax - xmin, ymin - xmin], 'color', 'k')
        % label
        text(0.95, 0.95, sprintf('N = %i', length(x)), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
        
        % ind hist
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 2);
        histogram(x, linspace(xmin, xmax, num_bins));
        xlabel('R^2_{ind}', 'interpreter', 'tex')
        xlim([xmin, xmax])
        % label
        text(0.95, 0.95, sprintf('median = %1.2g', median(x)), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
        
        % aff hist
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 3);
        histogram(y, linspace(ymin, ymax, num_bins));
        xlabel('R^2_{affine} - R^2_{ind}', ...
            'interpreter', 'tex')
        xlim([ymin, ymax])
        % label
        text(0.95, 0.95, sprintf('median = %1.2g', median(y)), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
        
        if ds == num_datasets && all_expts == 1 && num_datasets > 1
            % extended aff vs ind
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 1);
            indx_beg = 0;
            indx_end = -1;
            for dss = 1:num_datasets
                indx_end = indx_beg + size(r2s{dss, 1}, 1);
                plot( ...
                    qi_all{1}(indx_beg+1:indx_end), ...
                    qi_all{2}(indx_beg+1:indx_end), '.');
                hold on
                indx_beg = indx_end;
            end            
            xlabel('R^2_{ind}', 'interpreter', 'tex')
            ylabel('R^2_{affine} - R^2_{ind}', ...
                'interpreter', 'tex')
            xlim([xmin, xmax])
            ylim([ymin, ymax]) 
            % draw line
            line([xmin, xmax], [ymax - xmin, ymin - xmin], 'color', 'k')
            % label
            text(0.95, 0.95, sprintf('N = %i', length(qi_all{1})), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            clean_plot

            % ind hist
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 2);
            histogram(qi_all{1}, linspace(xmin, xmax, num_bins));
            xlabel('R^2_{ind}', 'interpreter', 'tex')
            xlim([xmin, xmax])
            % label
            text(0.95, 0.95, sprintf('median = %1.2g', median(qi_all{1})), ...
                'units', 'normalized', ...
                'horizontalalignment', 'right', ...
                'verticalalignment', 'top')
            clean_plot

            % aff hist
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 3);
            histogram(qi_all{2}, linspace(ymin, ymax, num_bins));
            xlabel('R^2_{affine} - R^2_{ind}', ...
                'interpreter', 'tex')
            xlim([ymin, ymax])
            % label
            text(0.95, 0.95, sprintf('median = %1.2g', median(qi_all{2})), ...
                'units', 'normalized', ...
                'horizontalalignment', 'right', ...
                'verticalalignment', 'top')
            clean_plot
                        
        end
    end
        
    if plot_type.model_scatter
    
        % --- plot r2s
        num_cols = 4;
        all_expts = 1;    % 1 to append a row for all expts combined
        plot_scatter = 1; % 0 to plot qi diff hists instead of scatter
        num_bins = 30;
        if all_expts == 1
            off = 1;
        else
            off = 0;
        end
        if datasets(ds) < 100
            if plot_scatter
                xmin = 0; xmax = 1.0; ymin = 0; ymax = 1.0;
            else
                xmin = -0.5; xmax = 1;
                %xmin = -0.5; xmax = 0.5;
            end
        elseif datasets(ds) >= 200
            if plot_scatter
                xmin = 0; xmax = 1.0; ymin = 0; ymax = 1.0;
            else
                xmin = -0.5; xmax = 1;
                %xmin = -0.5; xmax = 0.5;
            end
        else
            if plot_scatter
                xmin = 0; xmax = 0.7; ymin = 0; ymax = 0.7;
            else
%                 xmin = -0.25; xmax = 0.5;
                xmin = -0.05; xmax = 0.12;
            end
        end
        
        idx.ind = 1;
        idx.add = 2;
        idx.gor = 3;
        idx.mul = 4;
        idx.lin = 5;
        idx.aff = 6;
        
        % extended mult vs goris
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 1);
        x = (r2s{ds, idx.gor} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.gor} = [qi_all{idx.gor}; x(:)];
        y = (r2s{ds, idx.mul} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.mul} = [qi_all{idx.mul}; y(:)];
        if plot_scatter
            plot(x, y, '.k');
            line([0, 1], [0, 1], 'color', 'k')    
            xlabel(sprintf('Quality Index\nConstrained Mult'))
            ylabel(sprintf('Quality Index\nMultiplicative'))
            ylim([ymin, ymax])
        else
            z = y - x;
            temp = histogram(z, linspace(xmin, xmax, 20));
            ybounds = get(gca, 'ylim');
            line([0, 0], [0, ybounds(2)], 'color', 'k')
            line([median(z), median(z)], [0, ybounds(2)], ...
                'color', 'k', 'linestyle', ':')
            title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                'interpreter', 'tex')
        end
        xlim([xmin, xmax])
        text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
            signtest(x, y), length(r2s{ds, 1})), ...
             'units', 'normalized', ...
             'horizontalalignment', 'left', ...
             'verticalalignment', 'top')   
        clean_plot
        
        % aff vs lin
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 2);
        x = (r2s{ds, idx.lin} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.lin} = [qi_all{idx.lin}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        if plot_scatter
            plot(x, y, '.k');
            line([0, 1], [0, 1], 'color', 'k')
            xlabel(sprintf('Quality Index\nConstrained Affine'))
            ylabel(sprintf('Quality Index\nAffine'))
            ylim([ymin, ymax])
        else
            z = y - x;
            temp = histogram(z, linspace(xmin, xmax, 20));
            ybounds = get(gca, 'ylim');
            line([0, 0], [0, ybounds(2)], 'color', 'k')
            line([median(z), median(z)], [0, ybounds(2)], ...
                'color', 'k', 'linestyle', ':')
            title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                'interpreter', 'tex')
        end
        xlim([xmin, xmax])
        text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
            signtest(x, y), length(r2s{ds, 1})), ...
             'units', 'normalized', ...
             'horizontalalignment', 'left', ...
             'verticalalignment', 'top')
        clean_plot
        
        % aff vs extended add
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 3);
        x = (r2s{ds, idx.add} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        qi_all{idx.add} = [qi_all{idx.add}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        if plot_scatter
            plot(x, y, '.k');
            line([0, 1], [0, 1], 'color', 'k')
            xlabel(sprintf('Quality Index\nAdditive'))
            ylabel(sprintf('Quality Index\nAffine'))
            ylim([ymin, ymax])
        else
            z = y - x;
            temp = histogram(z, linspace(xmin, xmax, 20));
            ybounds = get(gca, 'ylim');
            line([0, 0], [0, ybounds(2)], 'color', 'k')
            line([median(z), median(z)], [0, ybounds(2)], ...
                'color', 'k', 'linestyle', ':')
            title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                'interpreter', 'tex')
        end
        xlim([xmin, xmax])
        text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
            signtest(x, y), length(r2s{ds, 1})), ...
             'units', 'normalized', ...
             'horizontalalignment', 'left', ...
             'verticalalignment', 'top')
        clean_plot
        
        % aff vs extended mult
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 4);
        x = (r2s{ds, idx.mul} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.mul} = [qi_all{idx.mul}; x(:)];
        y = (r2s{ds, idx.aff} - r2s{ds, idx.ind}) ./ ...
            (1 - r2s{ds, idx.ind});
        %qi_all{idx.aff} = [qi_all{idx.aff}; y(:)];
        if plot_scatter
            plot(x, y, '.k');
            line([0, 1], [0, 1], 'color', 'k')
            xlabel(sprintf('Quality Index\nMultiplicative'))
            ylabel(sprintf('Quality Index\nAffine'))
            ylim([ymin, ymax])
        else
            z = y - x;
            temp = histogram(z, linspace(xmin, xmax, 20));
            ybounds = get(gca, 'ylim');
            line([0, 0], [0, ybounds(2)], 'color', 'k')
            line([median(z), median(z)], [0, ybounds(2)], ...
                'color', 'k', 'linestyle', ':')
            title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                'interpreter', 'tex')
        end
        xlim([xmin, xmax])
        text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
            signtest(x, y), length(r2s{ds, 1})), ...
             'units', 'normalized', ...
             'horizontalalignment', 'left', ...
             'verticalalignment', 'top')
        clean_plot
        
        if ds == num_datasets && all_expts == 1
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
            if plot_scatter
                line([0, 1], [0, 1], 'color', 'k')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(qi_all{idx.gor}, qi_all{idx.mul}), ...
                    length(qi_all{2})), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')   
                xlabel(sprintf('Quality Index\nConstrained Mult'))
                ylabel(sprintf('Quality Index\nMultiplicative'))
                ylim([ymin, ymax])
            else
                z = y - x;
                temp = histogram(z, linspace(xmin, xmax, num_bins), ...
                    'edgecolor', 'none');
                ybounds = get(gca, 'ylim');
                line([0, 0], [0, ybounds(2)], 'color', 'k')
                line([median(z), median(z)], [0, ybounds(2)], ...
                    'color', 'k', 'linestyle', ':')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(x, y), length(x)), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                    'interpreter', 'tex')
            end
            xlim([xmin, xmax])
            clean_plot
            
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
            if plot_scatter
                line([0, 1], [0, 1], 'color', 'k')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(qi_all{idx.lin}, qi_all{idx.aff}), ...
                    length(qi_all{2})), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                xlabel(sprintf('Quality Index\nConstrained Affine'))
                ylabel(sprintf('Quality Index\nAffine'))
                ylim([ymin, ymax])
            else
                z = y - x;
                temp = histogram(z, linspace(xmin, xmax, num_bins), ...
                    'edgecolor', 'none');
                ybounds = get(gca, 'ylim');
                line([0, 0], [0, ybounds(2)], 'color', 'k')
                line([median(z), median(z)], [0, ybounds(2)], ...
                    'color', 'k', 'linestyle', ':')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(x, y), length(x)), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                    'interpreter', 'tex')
            end
            xlim([xmin, xmax])
            clean_plot
            
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
            if plot_scatter
                line([0, 1], [0, 1], 'color', 'k')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(qi_all{idx.add}, qi_all{idx.aff}), ...
                    length(qi_all{2})), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                xlabel(sprintf('Quality Index\nAdditive'))
                ylabel(sprintf('Quality Index\nAffine'))
                ylim([ymin, ymax])
            else
                z = y - x;
                temp = histogram(z, linspace(xmin, xmax, num_bins), ...
                    'edgecolor', 'none');
                ybounds = get(gca, 'ylim');
                line([0, 0], [0, ybounds(2)], 'color', 'k')
                line([median(z), median(z)], [0, ybounds(2)], ...
                    'color', 'k', 'linestyle', ':')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(x, y), length(x)), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                    'interpreter', 'tex')
            end
            xlim([xmin, xmax])
            clean_plot
            
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
            if plot_scatter
                line([0, 1], [0, 1], 'color', 'k')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(qi_all{idx.mul}, qi_all{idx.aff}), ...
                    length(qi_all{2})), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')  
                xlabel(sprintf('Quality Index\nMultiplicative'))
                ylabel(sprintf('Quality Index\nAffine'))
                ylim([ymin, ymax]) 
            else
                z = y - x;
                temp = histogram(z, linspace(xmin, xmax, num_bins), ...
                    'edgecolor', 'none');
                ybounds = get(gca, 'ylim');
                line([0, 0], [0, ybounds(2)], 'color', 'k')
                line([median(z), median(z)], [0, ybounds(2)], ...
                    'color', 'k', 'linestyle', ':')
                text(0.05, 0.95, sprintf('p = %1.2g\nN = %i', ...
                    signtest(x, y), length(x)), ...
                     'units', 'normalized', ...
                     'horizontalalignment', 'left', ...
                     'verticalalignment', 'top')
                title(sprintf('\\DeltaQI = %3.2f', median(z)), ...
                    'interpreter', 'tex')
            end
            xlim([xmin, xmax])
            clean_plot
            
        end
        
    end
    
    if plot_type.model_compare
        
        use_all_stims = 0; % 0 for pred vs true fr scatter for a single stim
        
        if use_all_stims
            edges = linspace(-4, 4, 31);
            num_cols = 2;

    %         choose example neuron for plotting
            [~, neuron_indx] = min(abs((mean(r2s{ds, 2}, 2) - mean(r2s{ds, 1}, 2))));
%             [~, neuron_indx] = max(mean(r2s{ds, 2}, 2) - mean(r2s{ds, 1}, 2));

            for model = 1:num_models

                % calculate differences in true vs predicted frs
                diffs = datas{ds} - pred{ds, model};

                % plot difference in true vs predicted frs
                plot_indxs = (ds - 1) * num_cols + 1 : (ds -1) * num_cols + (num_cols - 1);
                subplot(num_datasets, num_cols, plot_indxs);
                plot(diffs(:, neuron_indx), '.');
                hold on
                xlabel('Trial number')
                xlim([-50, size(datas{ds}, 1) + 50])
                ylabel('True - predicted firing rate')
                %clean_plot
                set(gca, 'FontSize', fontsize)
                set(gca, 'XColor', 'k')
                set(gca, 'YColor', 'k')
                box off
                legend boxoff

                % plot histogram of differences
                plot_indxs = (ds - 1) * num_cols + num_cols;
                subplot(num_datasets, num_cols, plot_indxs);
                histogram(diffs(:, neuron_indx), edges, ...
                    'displaystyle', 'stairs')
                hold on
                %clean_plot
                set(gca, 'FontSize', fontsize)
                set(gca, 'XColor', 'k')
                set(gca, 'YColor', 'k')
                box off
                legend boxoff
            end
        else
%             edges = linspace(, 4, 31);
            num_cols = 2;
            stim_num = 7;
            neuron_indx = 9;
            if num_datasets > 1 && ds ~= 3
                neuron_indx = 1;
            end
            
    %         choose example neuron for plotting
%             [~, neuron_indx] = min(abs((mean(r2s{ds, 2}, 2) - mean(r2s{ds, 1}, 2))));
%             [~, neuron_indx] = max(mean(r2s{ds, 2}, 2) - mean(r2s{ds, 1}, 2));
            
            
            for model = 1:num_models

                indxs_stim = trial_ids(:, stim_num);
                indxs_stim = [indxs_stim{:}];

                % plot difference in true vs predicted frs
                plot_indxs = (ds - 1) * num_cols + 1 : (ds -1) * num_cols + (num_cols - 1);
                subplot(num_datasets, num_cols, plot_indxs);
                stim_resp = pred{ds, 1}(indxs_stim, neuron_indx).^2;
                stim_resp = repmat(mean(stim_resp), 1, length(stim_resp));
                plot(datas{ds}(indxs_stim, neuron_indx).^2, ...
                    stim_resp, '.');
                hold on
                plot(datas{ds}(indxs_stim, neuron_indx).^2, ...
                    pred{ds, 2}(indxs_stim, neuron_indx).^2, '.');
                xlabel('Observed spike count')
                xl = get(gca, 'xlim');
                ylim(xl)
                line([0, xl(2)], [0, xl(2)], 'color', 'k')
                
                ylabel('Predicted firing rate')
                %clean_plot
                set(gca, 'FontSize', fontsize)
                set(gca, 'XColor', 'k')
                set(gca, 'YColor', 'k')
                box off
                legend boxoff
                axis square
                
                % plot histogram of frs
                plot_indxs = (ds - 1) * num_cols + num_cols;
                subplot(num_datasets, num_cols, plot_indxs);
                histogram(datas{ds}(indxs_stim, neuron_indx).^2, 15); %, ...
%                     'displaystyle', 'stairs')
                hold on
                %clean_plot
                set(gca, 'FontSize', fontsize)
                set(gca, 'XColor', 'k')
                set(gca, 'YColor', 'k')
                box off
                legend boxoff
                axis square
            end
        end
    end
    
    if plot_type.coupling_vs_pref
            
        type = 1; % 1 for ori/dir pref on x-axis, 2 for osi/dsi
        num_cols = 4;
        all_expts = 1; % 1 to include all experiments at bottom
        if all_expts == 1
            off = 1;
        else
            off = 0;
        end
        
        x1 = osi{ds}(:); osi_thresh = 0.05;
        x2 = dsi{ds}(:); dsi_thresh = 0.05;
        x3 = ori_pref{ds}(:);
        x4 = dir_pref{ds}(:);
%             y1 = coupling{ds, 1}(:, 2); %mean(coupling{ds, 1}, 2);
%             y2 = coupling{ds, 2}(:, 2); %mean(coupling{ds, 2}, 2);
        y1 = mean(coupling{ds, 1}, 2);
        y2 = mean(coupling{ds, 2}, 2);

        osi_all = [osi_all; osi{ds}(:)];
        dsi_all = [dsi_all; dsi{ds}(:)];
        opr_all = [opr_all; ori_pref{ds}(:)];
        dpr_all = [dpr_all; dir_pref{ds}(:)];
        add_all = [add_all; y1];
        mul_all = [mul_all; y2];
        
        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 1);
        if type == 1
            x = x3(x1 > osi_thresh);
            y = y2(x1 > osi_thresh);
            plot(x, y, '.')
            xlabel('Orientation pref')
            ylabel(sprintf('Multiplicative\ncoupling'))
        else
            x = x1;
            y = y2;
            plot(x, y, '.')
            xlabel('OSI')
            ylabel(sprintf('Multiplicative\ncoupling'))
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
        
        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 2);
        if type == 1
            x = x3(x1 > osi_thresh);
            y = y1(x1 > osi_thresh);
            plot(x, y, '.')
            xlabel('Orientation pref')
            ylabel(sprintf('Additive\ncoupling'))
        else
            x = x1;
            y = y1;
            plot(x, y, '.')
            xlabel('OSE')
            ylabel(sprintf('Additive\ncoupling'))
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot

        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 3);
        if type == 1
            x = x4(x2 > dsi_thresh);
            y = y2(x2 > dsi_thresh);
            plot(x, y, '.')
            xlabel('Direction pref')
            ylabel(sprintf('Multiplicative\ncoupling'))
        else
            x = x2;
            y = y2;
            plot(x, y, '.')
            xlabel('DSI')
            ylabel(sprintf('Multiplicative\ncoupling'))
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
        
        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 4);
        if type == 1
            x = x4(x2 > dsi_thresh);
            y = y1(x2 > dsi_thresh);
            plot(x, y, '.')
            xlabel('Direction pref')
            ylabel(sprintf('Additive\ncoupling'))
        else
            x = x2;
            y = y1;
            plot(x, y, '.')
            xlabel('DSI')
            ylabel(sprintf('Additive\ncoupling'))
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
         clean_plot
         
         if ds == num_datasets && all_expts == 1
             
            % ===
            subplot(num_datasets + off, num_cols, ds * num_cols + 1);
            for dss = 1:num_datasets
                x1 = osi{dss}(:); osi_thresh = 0.05;
                x2 = dsi{dss}(:); dsi_thresh = 0.05;
                x3 = ori_pref{dss}(:);
                x4 = dir_pref{dss}(:);
                y1 = mean(coupling{dss, 1}, 2);
                y2 = mean(coupling{dss, 2}, 2);                
                if type == 1
                    x = x3(x1 > osi_thresh);
                    y = y2(x1 > osi_thresh);
                    plot(x, y, '.')
                    xlabel('Orientation pref')
                    ylabel(sprintf('Multiplicative\ncoupling'))
                else
                    x = x1;
                    y = y2;
                    plot(x, y, '.')
                    xlabel('OSI')
                    ylabel(sprintf('Multiplicative\ncoupling'))
                end
                hold on
            end

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 2);
            for dss = 1:num_datasets
                x1 = osi{dss}(:); osi_thresh = 0.05;
                x2 = dsi{dss}(:); dsi_thresh = 0.05;
                x3 = ori_pref{dss}(:);
                x4 = dir_pref{dss}(:);
                y1 = mean(coupling{dss, 1}, 2);
                y2 = mean(coupling{dss, 2}, 2);
                if type == 1
                    x = x3(x1 > osi_thresh);
                    y = y1(x1 > osi_thresh);
                    plot(x, y, '.')
                    xlabel('Orientation pref')
                    ylabel(sprintf('Additive\ncoupling'))
                else
                    x = x1;
                    y = y1;
                    plot(x, y, '.')
                    xlabel('OSE')
                    ylabel(sprintf('Additive\ncoupling'))
                end
                hold on
            end
            
            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 3);
            for dss = 1:num_datasets
                x1 = osi{dss}(:); osi_thresh = 0.05;
                x2 = dsi{dss}(:); dsi_thresh = 0.05;
                x3 = ori_pref{dss}(:);
                x4 = dir_pref{dss}(:);
                y1 = mean(coupling{dss, 1}, 2);
                y2 = mean(coupling{dss, 2}, 2);
                if type == 1
                    x = x4(x2 > dsi_thresh);
                    y = y2(x2 > dsi_thresh);
                    plot(x, y, '.')
                    xlabel('Direction pref')
                    ylabel(sprintf('Multiplicative\ncoupling'))
                else
                    x = x2;
                    y = y2;
                    plot(x, y, '.')
                    xlabel('DSI')
                    ylabel(sprintf('Multiplicative\ncoupling'))
                end
                hold on
            end

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 4);
            for dss = 1:num_datasets
                x1 = osi{dss}(:); osi_thresh = 0.05;
                x2 = dsi{dss}(:); dsi_thresh = 0.05;
                x3 = ori_pref{dss}(:);
                x4 = dir_pref{dss}(:);
                y1 = mean(coupling{dss, 1}, 2);
                y2 = mean(coupling{dss, 2}, 2);    
                if type == 1
                    x = x4(x2 > dsi_thresh);
                    y = y1(x2 > dsi_thresh);
                    plot(x, y, '.')
                    xlabel('Direction pref')
                    ylabel(sprintf('Additive\ncoupling'))
                else
                    x = x2;
                    y = y1;
                    plot(x, y, '.')
                    xlabel('DSI')
                    ylabel(sprintf('Additive\ncoupling'))
                end
                hold on
            end     

            % LINES
            % ===
            subplot(num_datasets + off, num_cols, ds * num_cols + 1);
            if type == 1
                x = opr_all(osi_all > osi_thresh);
                y = mul_all(osi_all > osi_thresh);
            else
                x = osi_all;
                y = mul_all;
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
%             xmin = floor(min(x) / ax_fac) * ax_fac; 
%             xmax = ceil(max(x) / ax_fac) * ax_fac;
            xmin = 0; xmax = 180;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            clean_plot

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 2);
            if type == 1
                x = opr_all(osi_all > osi_thresh);
                y = add_all(osi_all > osi_thresh);
            else
                x = osi_all;
                y = add_all;
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
%             xmin = floor(min(x) / ax_fac) * ax_fac; 
%             xmax = ceil(max(x) / ax_fac) * ax_fac;
            xmin = 0; xmax = 180;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            clean_plot

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 3);
            if type == 1
                x = dpr_all(dsi_all > dsi_thresh);
                y = mul_all(dsi_all > dsi_thresh);
            else
                x = dsi_all;
                y = mul_all;
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
%             xmin = floor(min(x) / ax_fac) * ax_fac; 
%             xmax = ceil(max(x) / ax_fac) * ax_fac;
            xmin = 0; xmax = 360;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            clean_plot

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 4);
            if type == 1
                x = dpr_all(dsi_all > dsi_thresh);
                y = add_all(dsi_all > dsi_thresh);
            else
                x = dsi_all;
                y = add_all;
            end
            n = sum(~isnan(x));
            lm = fitlm(x, y);
            ax_fac = 1.05;
%             xmin = floor(min(x) / ax_fac) * ax_fac; 
%             xmax = ceil(max(x) / ax_fac) * ax_fac;
            xmin = 0; xmax = 360;
            line([xmin, xmax], ...
                 [lm.Coefficients{1,1} + xmin * lm.Coefficients{2,1}, ...
                  lm.Coefficients{1,1} + xmax * lm.Coefficients{2,1}], ...
                 'color', 'k')
            xlim([xmin, xmax])
            text(0.95, 0.95, ...
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
             clean_plot
         end
    end
    
    if plot_type.coup_lvs_scatter

        num_cols = 2;
        all_expts = 0; % 1 to include all experiments at bottom
        if all_expts == 1
            off = 1;
        else
            off = 0;
        end
        
        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 1);
        x = mean(coupling{ds, 1}, 2);
        y = mean(coupling{ds, 2}, 2);
        add_all = [add_all; x];
        mul_all = [mul_all; y];
        plot(x, y, '.')
        xlabel('Additive weight')
        ylabel('Multiplicative weight')
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
         clean_plot
        
        % ===
        subplot(num_datasets + off, num_cols, (ds - 1) * num_cols + 2);
        x = lvs{ds, 1};
        y = lvs{ds, 2};
        lvs_all{1} = [lvs_all{1}; lvs{ds, 1}(:)];
        lvs_all{2} = [lvs_all{2}; lvs{ds, 2}(:)];
        plot(x, y, '.')
%         for i = 1:12
%             subplot(4,3,i)
%             hue = i / 12;
%             rgb = hsv2rgb([hue, 1, 1]);
%             plot(x(i:12:end), y(i:12:end), '.', 'color', rgb)
%             xlim([-10, 10])
%             ylim([-5, 10])
%             hold on;
%         end
        xlabel('Additive LV')
        ylabel('Multiplicative LV')
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
             sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                     corr(x, y), lm.Coefficients{2, 4}, n), ...
             'units', 'normalized', ...
             'horizontalalignment', 'right', ...
             'verticalalignment', 'top')
        clean_plot
         
        if ds == num_datasets && all_expts == 1
            
            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 1);
            x = add_all;
            y = mul_all;
            plot(x, y, '.')
            xlabel('Additive weight')
            ylabel('Multiplicative weight')
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
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
             clean_plot

            % ===
            subplot(num_datasets + off, num_cols, (ds) * num_cols + 2);
            x = lvs_all{1};
            y = lvs_all{2};
            plot(x, y, '.')
            xlabel('Additive LV')
            ylabel('Multiplicative LV')
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
                 sprintf('r = %1.2f\np = %1.2g\nN = %i', ...
                         corr(x, y), lm.Coefficients{2, 4}, n), ...
                 'units', 'normalized', ...
                 'horizontalalignment', 'right', ...
                 'verticalalignment', 'top')
            clean_plot
        end
                
    end
    
    if plot_type.lgn_boxplots
                
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
        
        vals_mat = NaN(length(vals{1}), num_models-1);
        legend_str = {};
        colors = [];
        for i = 1:num_models-1
            vals_mat(:, i) = (vals{i+1}(:) - vals{1}(:)) ./ ...
                (1 - vals{1}(:)); % get QI
            legend_str = [legend_str, model_strs2{i+1}];
            colors = [colors; model_colors{i+1}];
        end

        % calculate p-values
        pvals{ds} = NaN(num_models-1);
        pvals_nonpar{ds} = NaN(num_models-1);
        for i = 2:num_models-1
            for k = 1:(i-1)
                [~, pvals{ds}(i, k)] = ...
                    ttest(vals_mat(:, i), vals_mat(:, k));
                pvals_nonpar{ds}(i, k) = ...
                   signtest(vals_mat(:, i), vals_mat(:, k));
            end
        end

        % --- plot d2
        subplot(num_datasets, 1, ds)
        if size(vals_mat, 2) < 20
            plotstyle = 'traditional';
        else
            plotstyle = 'compact';
        end

        if ds > num_datasets
            h = boxplot(vals_mat, ...
                'labels', legend_str, ...
                'labelorientation', 'inline', ...
                'colors', colors, ...
                'plotstyle', plotstyle, ...
                'symbol', '.');        
            set(h, 'LineWidth', 1)
        else
            h = boxplot(vals_mat, ...
                'colors', colors, ...
                'plotstyle', plotstyle, ...
                'symbol', '.');        
            set(h, 'LineWidth', 1)
        end
        ylabel('Quality Index')
    end
    
    if plot_type.extended_aff2
        % plots median value of distribution over neurons (after avg'ing 
        % over xv folds)
        vals = cell(num_models, 1);
        for i = 1:num_models
            if datasets(ds) < 100
                vals{i} = median(r2s{ds, i}, 2);
            else
                vals{i} = mean(r2s{ds, i}, 2); % avg r2s over neurons
            end
        end
        
        for i = 1:num_models
            qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
        end
        
        vals_mat = NaN(num_models, 1);
        for i = 1:num_models
            vals_mat(i) =  median(qi_all{i});
        end

        % calculate p-values
        pvals{ds} = NaN(num_models);
        pvals_nonpar{ds} = NaN(num_models);
        for i = 2:num_models
            for k = 1:(i-1)
                [~, pvals{ds}(i, k)] = ...
                    ttest(qi_all{i}, qi_all{k});
                pvals_nonpar{ds}(i, k) = ...
                   signtest(qi_all{i}, qi_all{k});
            end
        end

        % --- plot d2
        % just plot average
        vals_mat = reshape(vals_mat, add_rows, mul_rows);
        vals_mat(1, 1) = NaN; % don't plot zeroed out stim model
        subplot(num_datasets, 1, ds)
        imagesc(vals_mat);
        set(gca, 'ydir', 'normal')
        set(gca, 'xticklabel', 0:mul_rows-1)
        set(gca, 'yticklabel', 0:add_rows-1)
        ylabel('Additive LVs')
        xlabel('Multiplicative LVs')
        
    end
    
    if plot_type.extended_aff
        combine_type = 1;
        vals = cell(num_models, 1);
        if combine_type == 2
            % avg pop r2s over xv folds
            for i = 1:num_models
                vals{i} = median(r2s{ds, i}, 1); % median r2s over neurons
            end
            for i = 1:num_models
                qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
%                 qi_all{i} = vals{i}(:);
            end
            vals_mat = NaN(num_models, 1);
            for i = 1:num_models
                vals_mat(i) = mean(qi_all{i}); % avg r2s over xv folds
            end
        else
            % avg r2s over neurons
            for i = 1:num_models
                vals{i} = mean(r2s{ds, i}, 2); % avg r2s over xvs
            end
            for i = 1:num_models
                qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
%                 qi_all{i} = vals{i}(:);
            end
            vals_mat = NaN(num_models, 1);
            for i = 1:num_models
                vals_mat(i) = mean(qi_all{i}); % median r2s over neurons
            end
        end
        
        % calculate p-values
%         pvals{ds} = NaN(num_models);
%         pvals_nonpar{ds} = NaN(num_models);
%         for i = 2:num_models
%             for k = 1:(i-1)
%                 [~, pvals{ds}(i, k)] = ...
%                     ttest(qi_all{i}, qi_all{k});
%                 pvals_nonpar{ds}(i, k) = ...
%                    signtest(qi_all{i}, qi_all{k});
%             end
%         end

        % --- plot d2
        % just plot average
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
            if datasets(ds) < 100
                vals{i} = median(r2s{ds, i}, 1); % median?
                vals2{i} = mean(r2s{ds, i}, 2); % median?
            else
                vals{i} = mean(r2s{ds, i}, 1); % avg r2s over neurons
                vals2{i} = mean(r2s{ds, i}, 2);
            end
        end
        vals_mat = NaN(length(vals{1}), num_models);
        for i = 1:num_models
            vals_mat(:, i) = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
            qi_all{i} = (vals2{i}(:) - vals2{1}(:)) ./ (1 - vals2{1}(:));
        end
        
        % --- plot d2
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
        vals2 = cell(num_models, 1);
        for i = 1:num_models
            vals{i} = mean(r2s{ds, i}, 2); % avg r2s over xvs
            vals2{i} = mean(r2s{ds, i}, 1); % avg r2s over neurons
        end
        for i = 1:num_models
            qi_all{i} = (vals{i}(:) - vals{1}(:)) ./ (1 - vals{1}(:));
            qi_all2{i} = (vals2{i}(:) - vals2{1}(:)) ./ (1 - vals2{1}(:));
        end
        vals_mat = NaN(num_models, 1);
        vals_mat2 = NaN(10, num_models);
        for i = 1:num_models
            vals_mat(i) = mean(qi_all{i}); % median r2s over neurons
            vals_mat2(:, i) = qi_all2{i}(:);
        end
        
        % --- plot d2
        means = mean(vals_mat2, 1);
        stds = std(vals_mat2, [], 1) / sqrt(size(vals_mat2, 1));
        
        % calculate p-values
%         pvals{ds} = NaN(num_models);
%         pvals_nonpar{ds} = NaN(num_models);
%         for i = 2:num_models
%             for k = 1:(i-1)
%                 [~, pvals{ds}(i, k)] = ...
%                     ttest(qi_all{i}, qi_all{k});
%                 pvals_nonpar{ds}(i, k) = ...
%                    signtest(qi_all{i}, qi_all{k});
%             end
%         end

        % --- plot d2
        % just plot average
        vals_mat1 = vals_mat(1:add_rows*mul_rows);
        vals_mat1(1) = NaN; % don't plot zeroed out stim model
        num_lvs = (1:length(vals_mat1)) - 1;
        num_lvs = floor(num_lvs / add_rows) + repmat(0:9, 1, add_rows);
        subplot(num_datasets, 1, ds)
        plot(num_lvs, vals_mat1, '.');
        hold on;
        indxs = (add_rows * mul_rows + 1) : num_models;
        errorbar(means(indxs)', stds(indxs)')
        
%         set(gca, 'ydir', 'normal')
%         set(gca, 'xticklabel', 0:mul_rows-1)
%         set(gca, 'yticklabel', 0:add_rows-1)
        ylabel('QI')
        xlabel('Number of LVs')
    end
    

    if plot_type.boxplots == 1
        vals_mat = NaN(length(vals{1}), num_models);
        legend_str = {};
        colors = [];
        for i = 1:num_models
            vals_mat(:, i) = vals{i}(:);
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
        if size(vals_mat, 2) < 10
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
            legend_str = [legend_str, model_strs2{i}];
            colors = [colors; model_colors{i}];
        end
        
        % --- plot d2
        means = mean(vals_mat, 1);
        stds = std(vals_mat, [], 1) / sqrt(size(vals_mat, 1));
        errorbar(means(1:5), stds(1:5))
        hold on
        errorbar(means(6:end), stds(6:end))
        ylabel('R^2')        
    end

   
    clean_plot

end
