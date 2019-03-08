function [fits_stim, meas_stim] = fitStimModels(io_struct, data_struct)
% fit stimulus models
% 
% INPUT:
%   io_struct (struct): saving info
%       saving (bool): 1 to save model output
%       overwrite (bool): 1 to overwrite models if they already exist
%       model_dir (str): sub-directory inside xv_dir for results
%       sub_dir (str): sub-directory inside model_dir for results
%       custom_ext (str): modify algorithmically generated filename
%   data_struct
%       dataset_name (str): see getDatasetStrings.m for options
%       normalize (bool):
%       fit_type (str): 'full' | 'sloo'
%       trial_avg (bool): 1 to model activity averaged over full trial;
%           otherwise activity is modeled at native resolution
%       data_type (str): determines noise distribution of model
%           'fr' | 'spikes' | '2p'
%       num_folds (scalar): number of folds to divide data into
%       num_xvs (scalar): number of folds to actually fit and evaluate
%       rng_seed (scalar): seed to determine tr/xv indices

%% *********************** parse input ************************************

% load/save variables
saving = io_struct.saving;
overwrite = io_struct.overwrite;
model_dir = io_struct.model_dir;
sub_dir = io_struct.sub_dir;
custom_ext = io_struct.custom_ext;

% user variables
dataset_name = data_struct.dataset_name;
trial_avg = data_struct.trial_avg;
data_type = data_struct.data_type;
num_folds = data_struct.num_folds;
num_xvs = data_struct.num_xvs;
rng_seed = data_struct.rng_seed;

% fitting variables
optim_params.MaxIter = 5000;

% save all info in new struct
fit_params.io_struct = io_struct;
fit_params.data_struct = data_struct;
fit_params.fit_date = date;
fit_params.matlab_info = ver;
fit_params = orderfields(fit_params);

% load and normalize data
[expt_struct, data, trial_ids, ~, results_dir] = loadData(dataset_name);
if data_struct.normalize
    data = normalizeData(dataset_name, data);
end
num_cells = size(data, 2);

% get processed input data
[xmat, stim_params] = buildStimMatrix( ...
    dataset_name, expt_struct, data, trial_ids, trial_avg);
if trial_avg && dataset_name(1) == 'K'
    [data, trial_ids] = getTrialMeanData(data, expt_struct, trial_ids);
    results_dir = sprintf('%s_avg', results_dir);
end

% calculate tr/xv indices for new trial ids
xv_dir = sprintf('%02d_fold', num_folds);
[indx_reps, ~] = getIndices(num_folds, rng_seed, trial_ids);

%% ************************* fit models ***********************************
if ~isempty(custom_ext)
    filename = sprintf('fit_stim_%s.mat', custom_ext);
else
    filename = 'fit_stim';
end
save_file = fullfile(results_dir, xv_dir, model_dir, sub_dir, filename);   

% only fit model if it doesn't already exist OR are overwriting old version
if ~exist(save_file, 'file') || overwrite

    if exist(save_file, 'file')
        fprintf('Overwriting file %s\n', save_file)
    end
    
    % get noise distribution from data_type
    switch data_type
        case {'fr', '2p'}
            noise_dist = 'gaussian';
            spiking_nl = 'lin';
        case 'spikes'
            noise_dist = 'poisson';
            spiking_nl = 'softplus';
    end
    
    % save model outputs
    clear fits
    fits(num_cells, num_xvs) = NIM();
    meas.r2s = NaN(num_cells, num_xvs);

    % set up loop counter
    fprintf('Dataset: %s\n', dataset_name)
    loop_counter = 0;
    loop_start = 1;
    loop_end = num_cells * num_xvs;
    model_str = 'stim';

    for c = 1:num_cells

        robs = data(:, c);

        % num_xvs-fold cross-validation
        for nxv = 1:num_xvs

            % determine training/xv indices
            indx_tr = [indx_reps{setdiff(1:num_folds, nxv)}];
            indx_tr = sort(indx_tr(:));
            indx_xv = sort(indx_reps{nxv});

            % print updates
            loop_counter = loop_counter + 1;
            msg = sprintf('Fitting %s model %04g of %04g', ...
                          model_str, loop_counter, loop_end);
            if loop_counter ~= loop_start
                fprintf([repmat('\b', 1, length(msg)), msg])
            else
                fprintf(msg)
            end

            % initialize model - define subunits as linear and excitatory
            NL_types = 'lin';
            mod_signs = 1;
            fit0 = NIM( ...
                stim_params, NL_types, mod_signs, ...
                'spkNL', spiking_nl, ...
                'noise_dist', noise_dist);

            if num_folds == 1
                fits(c, nxv) = fit0.fit_filters( ...
                    robs, xmat, indx_tr, ...
                    'silent', 1, ...
                    'optim_params', optim_params);
            else
                fits(c, nxv) = fit0.reg_path( ...
                    robs, xmat, ...
                    indx_tr, indx_xv, ...
                    'silent', 1, ...
                    'lambdaid', 'l2', ...
                    'optim_params', optim_params);                
            end
            
            % predict activity on xv data
            [~, pred] = fits(c, nxv).eval_model(robs, xmat, indx_xv);
            meas.r2s(c, nxv) = getSimpleR2(robs(indx_xv), pred);

        end % nxv
    end % c
    fprintf('\n')

    % save overall results
    meas_stim = meas;
    flds = fields(meas_stim);
    for fld = 1:length(flds)
        meas_stim.(flds{fld}) = squeeze(meas.(flds{fld}));
    end
    fits_stim = squeeze(fits);
    fit_params_stim = fit_params;
    if saving
        if ~isdir(fullfile(results_dir, xv_dir, model_dir, sub_dir))
            mkdir(fullfile(results_dir, xv_dir, model_dir, sub_dir))
        end
        save(save_file, 'meas_stim', 'fits_stim', 'fit_params_stim')
    end
    
elseif exist(save_file, 'file')
    fprintf('%s already exists; skipping\n\n', save_file)
    fits_stim = [];
    meas_stim = [];
end

