function fitGams(net_io, net_arch, net_fit, data_struct)
% INPUTS:
%   net_io (struct): saving info
%       saving (bool)
%       overwrite (bool)
%       model_dir (str)
%       sub_dir (str)
%       filename_ext (str)
%       custom_ext (str)
%       model_dir_stim (str)
%       sub_dir_stim (str)
%       custom_ext_stim (str)
%   net_arch (struct): model info
%       see buildModelFitStruct.m for fields
%   net_fit (struct): fitting info
%       see buildModelFitStruct.m for fields
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
%       eval_only (bool): don't fit model; load/eval/resave
%       pos_stim_mod (bool): only fit neurons with positive stim model r2s

%% *********************** parse input ************************************

% load/save variables
saving = net_io.saving;
overwrite = net_io.overwrite;
model_dir = net_io.model_dir;
sub_dir = net_io.sub_dir;
filename_ext = net_io.filename_ext;
custom_ext = net_io.custom_ext;
model_dir_stim = net_io.model_dir_stim;
sub_dir_stim = net_io.sub_dir_stim;
custom_ext_stim = net_io.custom_ext_stim;

% user variables
dataset_name = data_struct.dataset_name;
trial_avg = data_struct.trial_avg;
data_type = data_struct.data_type;
num_folds = data_struct.num_folds;
num_xvs = data_struct.num_xvs;
rng_seed = data_struct.rng_seed;

%% *********************** load necessary files ***************************

% load and normalize data
[expt_struct, data, trial_ids, ~, results_dir] = loadData(dataset_name);
if data_struct.normalize
    data = normalizeData(dataset_name, data);
end
num_cells = size(data, 2);

% load stim models if necessary
if (any(strcmp({net_arch(:).init}, 'stim')) || data_struct.pos_stim_mod) ...
        && ~data_struct.eval_only
    xv_dir = sprintf('%02d_fold', num_folds);
    if ~isempty(custom_ext_stim)
        filename = sprintf('fit_stim_%s.mat', custom_ext_stim);
    else
        filename = 'fit_stim.mat';
    end
    stim_file_loc = fullfile(results_dir, xv_dir, ...
        model_dir_stim, sub_dir_stim, filename);
    try
        load(stim_file_loc, 'fits_stim', 'fit_params_stim', 'meas_stim');
    catch
        fprintf(['stim models for dataset %s do not exist; ', ...
                 'creating now...\n'], dataset_name)
        io_struct = net_io;
        io_struct.model_dir = model_dir_stim;
        io_struct.sub_dir = sub_dir_stim;
        io_struct.custom_ext = custom_ext_stim;
        [fits_stim, meas_stim] = fitStimModels(io_struct, data_struct);
    end
    
    if any(strcmp({net_arch(:).init}, 'stim'))
        net_arch(strcmp({net_arch(:).init}, 'stim')).input_loc = ...
            stim_file_loc;    
    end
    
else
    fits_stim = NaN(num_cells, num_xvs);
end

% get rid of neurons with negative stim r2s
if data_struct.pos_stim_mod
    r2s = mean(meas_stim.r2s, 2);
    neg_vals = r2s < 0;
    data(:, neg_vals) = [];
    fits_stim(neg_vals, :) = [];
    num_cells = size(data, 2);
end

% switch out placeholders with actual number of cells
for i = 1:length(net_arch)
   for j = 1:length(net_arch(i).layers)
       if net_arch(i).layers(j) == -1
           net_arch(i).layers(j) = num_cells;
       end
   end
end

% get processed input data
[xmat, input_params] = buildGamXmats( ...
    dataset_name, net_arch, data, expt_struct, trial_ids, trial_avg);
if trial_avg && dataset_name(1) == 'K'
    [data, trial_ids] = getTrialMeanData(data, expt_struct, trial_ids);
    %results_dir = sprintf('%s_avg', results_dir);
    change_xv_dir = 0;
elseif trial_avg && dataset_name(1) == 's'
    %results_dir = sprintf('%s_avg', results_dir);
    num_reps = size(trial_ids, 1);
    num_folds = num_reps;
    data_struct.num_folds = num_reps;
    num_xvs = num_reps;
    data_struct.num_xvs = num_reps;
    change_xv_dir = 1;
else
    change_xv_dir = 0;
end

% calculate tr/xv indices for new trial ids
if change_xv_dir
    xv_dir = '10_fold';
else
    xv_dir = sprintf('%02d_fold', num_folds);
end
[indx_reps, ~] = getIndices(num_folds, rng_seed, trial_ids);

% get noise distribution from data_type
switch data_type
    case {'fr', '2p'}
        if isnan(net_fit.noise_dist)
            net_fit.noise_dist = 'gauss';
        end
        if isnan(net_fit.spiking_nl)
            net_fit.spiking_nl = 'lin';
        end
    case 'spikes'
        if isnan(net_fit.noise_dist)
            net_fit.noise_dist = 'poiss';
        end
        if isnan(net_fit.spiking_nl)
            net_fit.spiking_nl = 'softplus';
        end
end

%% ********************** fit models **************************************
if ~isempty(custom_ext)
    model_str = sprintf('%s_%s', filename_ext, custom_ext);
else
    model_str = filename_ext;
end
filename = sprintf('fit_gam_%s.mat', model_str);
save_file = fullfile(results_dir, xv_dir, model_dir, sub_dir, filename);  

% only fit model if it doesn't already exist OR are overwriting old version
if ~exist(save_file, 'file') || overwrite || data_struct.eval_only

    if data_struct.eval_only
        fprintf('Evaluating models in file %s\n', save_file)
        fprintf('Loading models...')
        load(save_file, 'fits_gam', 'meas_gam');
        fprintf('done\n')
        trained_gams = fits_gam; clear fits_gam;
        trained_meas_gam = meas_gam; clear meas_gam;
        model_op = 'Evaluating';
    else
        model_op = 'Fitting';
    end
    if exist(save_file, 'file')
        fprintf('Overwriting file %s\n', save_file)
    end
        
    % save model outputs
    fits_gam = cell(num_xvs, 1);
    meas_gam.r2s = cell(num_xvs, 1);
    meas_gam.fit_struct = cell(num_xvs, 1);

    % set up loop counter
    fprintf('Dataset: %s\n', dataset_name)
    loop_counter = 0;
    loop_start = 1;
    loop_end = num_xvs;
    
    % loop through fits
    for nxv = 1:num_xvs

        % determine training/xv indices
        indx_tr = [indx_reps{setdiff(1:num_folds, nxv)}];
        indx_tr = sort(indx_tr(:));
        indx_xv = sort(indx_reps{nxv});
        
        % print updates
        loop_counter = loop_counter + 1;
        msg = sprintf('%s %s model %02g of %02g', ...
            model_op, model_str, loop_counter, loop_end);
        if loop_counter ~= loop_start
            fprintf([repmat('\b', 1, length(msg)), msg])
        else
            fprintf(msg)
        end

        % fit model
        if data_struct.eval_only
            [r2s, fit_struct] = evalGam( ...
                trained_gams{nxv}, data, xmat, indx_tr, indx_xv);
            net = trained_gams{nxv};
            fit_struct.time = trained_meas_gam.fit_struct{nxv}.time;
        else
            [net, r2s, fit_struct] = fitGamSeries( ...
                data, xmat, input_params, fits_stim(:, nxv), [], ...
                indx_tr, indx_xv, net_arch, net_fit);
        end

        % store results
        fits_gam{nxv} = net;
        meas_gam.r2s{nxv} = r2s;
        meas_gam.fit_struct{nxv} = fit_struct;

    end % num_xvs
    fprintf('\n\n')

    % save
    if saving
        if ~isdir(fullfile(results_dir, xv_dir, model_dir, sub_dir))
            mkdir(fullfile(results_dir, xv_dir, model_dir, sub_dir))
        end
        save(save_file, 'fits_gam', 'meas_gam', 'data_struct', ...
             'net_io', 'net_arch', 'net_fit');
    end
        
elseif exist(save_file, 'file')
    fprintf('%s already exists; skipping\n\n', save_file)
end
