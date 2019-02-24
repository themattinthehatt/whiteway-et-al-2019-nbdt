function [xmat, stim_params] = buildStimMatrix( ...
    dataset_name, expt_struct, data, trial_ids, trial_avg)
% fit lagged stim model regressing on visual stimulus onset
%
% INPUTS:
%   dataset_name (str)
%   expt_struct (struct)
%   data (T x num_cells matrix)
%   trial_ids (num_trials x 1 vector)
%   trial_avg (bool)
   
if dataset_name(1) == 'm' || dataset_name(1) == 's' || ...
        dataset_name(1) == 'C' || dataset_name(1) == 'p' || ...
        dataset_name(1) == 'k'
    % kohn data / lgn spiking data / kiani pfc data

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
    
elseif dataset_name(1) == 'K'
    % lgn data 
    
    if trial_avg
        stim_frames = expt_struct.stims;
        num_trials = size(stim_frames, 1);
        num_stims = size(stim_frames, 2);
        stim_onsets = zeros(2 * num_stims * num_trials, num_stims);
        for i = 1:num_trials
            for j = 1:num_stims
                stim_onsets((i-1) * 2 * num_stims + 2 * j - 1, j) = 1;
            end
        end
        input_lags = 2;
        input_tent_spacing = 1;
        input = stim_onsets;
        clear stim_onsets
    else
        epoch_frames = trial_ids;
        num_trials = size(epoch_frames, 1);
        num_stims = size(epoch_frames, 2);
        T = size(data, 1);
        epoch_onsets = zeros(T, num_stims);
        for i = 1:num_trials
            for j = 1:num_stims
                epoch_onsets(epoch_frames{i,j}(1), j) = 1;
            end
        end
        % full PSTH on each stim+blank presentation (160 frames)
        fr = expt_struct.fr;
        if fr > 13 && fr < 17
            % 15 fps; ~500ms between bin centers
            input_lags = 20;
            input_tent_spacing = 8;
        elseif fr > 28 && fr < 32
            % 30 fps; ~500ms between bin centers
            input_lags = 20;
            input_tent_spacing = 16;
        else
            error('Unhandled frame rate')
        end
        input = epoch_onsets;
        clear epoch_onsets
    end
    
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

