function [xmat, stim_params] = buildStimMatrix( ...
    dataset_name, expt_struct, data, trial_ids, trial_avg)
% fit lagged stim model regressing on visual stimulus onset
%
% INPUT:
%   dataset_name (str)
%   expt_struct (struct)
%   data (T x num_cells matrix)
%   trial_ids (num_trials x 1 vector)
%   trial_avg (bool)
   
if dataset_name(1) == 'v' || dataset_name(1) == 'p'
    epoch_frames = trial_ids;
    num_trials = size(epoch_frames, 1);
    num_stims = size(epoch_frames, 2);
    T = size(data, 1);
    epoch_onsets = zeros(T, num_stims);
    for i = 1:num_trials
        for j = 1:num_stims
            ii = epoch_frames{i,j};
            if ~isempty(ii)
                epoch_onsets(ii(1), j) = 1;
            end
        end
    end
    input_lags = 1;
    input_tent_spacing = 1;
    input = epoch_onsets;
    clear epoch_onsets
else
    error('dataset name "%s" does not have a buildStimMatrix function', ...
        dataset_name)
end

% create xmat from stim_onsets
stim_params = GAM.create_input_params( ...
    [input_lags, num_stims, 1], ...
    'boundary_conds', [0 Inf Inf], ...
    'tent_spacing', input_tent_spacing);
xmat{1} = GAM.create_time_embedding( ...
    input, ...
    stim_params);

