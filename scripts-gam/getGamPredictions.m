function [pred, xmat, data, indx_reps, signs, expt_struct] = ...
    getGamPredictions(data_struct, net_arch, fits, net_io, return_lvs)
% simple function for getting xv predictions from a set of gams
%
% INPUTS:
%   data_struct (struct)
%   net_io (struct)
%   net_arch (struct)
%
% OUTPUTS:
%

%% *********************** parse input ************************************

% user variables
dataset_name = data_struct.dataset_name;
trial_avg = data_struct.trial_avg;
data_type = data_struct.data_type;
num_folds = data_struct.num_folds;
num_xvs = data_struct.num_xvs;
rng_seed = data_struct.rng_seed;

% default to returning predicted lvs rather than predicted activity
if nargin < 5
    return_lvs = 1;
end

%% *********************** load necessary files ***************************

% load and normalize data
[expt_struct, data, trial_ids, ~, results_dir] = loadData(dataset_name);
if data_struct.normalize
    data = normalizeData(dataset_name, data);
end

% get rid of neurons with negative stim r2s
if isfield(data_struct, 'pos_stim_mod') && data_struct.pos_stim_mod == 1
    % load stim models
    model_dir_stim = net_io.model_dir_stim;
    sub_dir_stim = net_io.sub_dir_stim;
    custom_ext_stim = net_io.custom_ext_stim;
    xv_dir = sprintf('%02d_fold', num_folds);
    if ~isempty(custom_ext_stim)
        filename = sprintf('fit_stim_%s.mat', custom_ext_stim);
    else
        filename = 'fit_stim.mat';
    end
    stim_file_loc = fullfile(results_dir, xv_dir, ...
        model_dir_stim, sub_dir_stim, filename);
    load(stim_file_loc, 'meas_stim');
    
    % update data
    r2s = mean(meas_stim.r2s, 2);
    neg_vals = r2s < 0;
    data(:, neg_vals) = [];
end

% get processed input data
[xmat, ~] = buildGamXmats( ...
    dataset_name, net_arch, data, expt_struct, trial_ids, trial_avg);
if trial_avg && dataset_name(1) == 'K'
    [data, trial_ids] = getTrialMeanData(data, expt_struct, trial_ids);
end

% calculate tr/xv indices for new trial ids
[indx_reps, ~] = getIndices(num_folds, rng_seed, trial_ids);

if return_lvs
    % determine which subunit to get lvs from
    num_lvs = length(fits{1}.add_subunits);

    % loop through fits
    % pred = NaN(size(data, 1), num_lvs);
    pred = cell(num_lvs, 1);
    for i = 1:num_lvs
        if length(fits{1}.add_subunits(i).layers) == 4
            num_lvs_sub = length(fits{1}.add_subunits(i).layers(end-2).biases);
        elseif length(fits{1}.add_subunits(i).layers) == 2
            num_lvs_sub = length(fits{1}.add_subunits(i).layers(end-1).biases);
        end
        pred{i} = NaN(size(data, 1), num_lvs_sub);
    end
    signs = NaN(num_xvs, num_lvs);
else 
    pred = NaN(size(data));
    signs = NaN;
end

for nxv = 1:num_xvs

    % determine training/xv indices
    indx_tr = [indx_reps{setdiff(1:num_folds, nxv)}];
    indx_tr = sort(indx_tr(:));
    indx_xv = sort(indx_reps{nxv});

    % evaluate model
    if return_lvs
        for i = 1:num_lvs
            a = fits{nxv}.add_subunits(i).get_model_internals( ...
                xmat, 'indx_tr', indx_xv);
            if length(fits{nxv}.add_subunits(i).layers) == 4
                lvs = a{end-2}';
            elseif length(fits{nxv}.add_subunits(i).layers) == 2
                lvs = a{end-1}';
            end
%             signs(nxv, i) = sign(mean(lvs, 1));
            if length(a) > 1
%                 pred{i}(indx_xv, :) = signs(nxv, i) * lvs;
                pred{i}(indx_xv, :) = lvs;
            end        
        end
    else
        pred(indx_xv, :) = ...
            fits{nxv}.get_model_internals(xmat, 'indx_tr', indx_xv);
    end
    
end % num_xvs

