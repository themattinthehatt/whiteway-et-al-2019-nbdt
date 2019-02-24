% script to fit stim models on multiple datasets

%% ************************* setup ****************************************

dataset_nums = 30;

% load/save variables
io_struct.saving = 1;           % 0 for none, 1 to save, 2 for extra info
io_struct.overwrite = 1;        % perform fits even if they already exist
io_struct.model_dir = 'tuned_units_sig-60';       % sub-directory inside xv_dir for results
io_struct.sub_dir = '';         % sub-directory inside model_dir for results
io_struct.custom_ext = '';      % for modifications to standard filenames

% dataset variables
data_struct.bin_size = 0;       % ms; 0 for full trial
data_struct.data_type = 'fr';   % 'fr' | 'spikes' | '2p'
data_struct.num_folds = 5;      % number of folds to divide data into
data_struct.num_xvs = 5;        % number of folds to actually evaluate
data_struct.rng_seed = 0;       % seed for training/xv indices
data_struct.align_marker='sacc';% 'sacc' | 'stim'; align mark for pfc data
data_struct.only_sus = 0;
data_struct.only_tuned = 1;

% model variables
stim_struct.to_exclude.ob = []; % bandwidths to explicitly exclude
stim_struct.to_exclude.or = []; % orientations to explicitly exclude
stim_struct.to_include.ob = 60; % only include these bandwidths
stim_struct.to_include.or = []; % only include these orientations
stim_struct.num_lags = 1;
stim_struct.tent_spacing = 1;

%% ************************* fit models ***********************************

[dataset_names, bad_datasets] = getDatasetStrings(dataset_nums);

% iterate through datasets
for ds = 1:length(dataset_names)

    % print update header
    fprintf('\n========== Dataset %s ==========\n', dataset_names{ds})
    if bad_datasets(ds) == 1
        fprintf('Bad dataset; skipping\n\n')
        continue
    end
    data_struct.dataset_name = dataset_names{ds};
    
    % fit models
    fitStimModels(io_struct, data_struct, stim_struct);
    
end
