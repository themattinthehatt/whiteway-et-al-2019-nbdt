function [data, trial_ids] = getTrialMeanData(data, expt_struct, trial_ids)
% update data and trial_ids by averaging over trials
%
% INPUTS:
%   expt_struct (struct)
%   data (T x num_cells matrix)
%   trial_ids (num_trials x 1 vector)

% replace input values with mean over stim/blank indices
data = getTrialMeanBonin(data, expt_struct, 'mean');

% just use mean value from first bin of each stim
[num_trials, num_stims] = size(expt_struct.stims);
input_mean = zeros(2 * num_stims * num_trials, size(data, 2));
for i = 1:num_trials
    for j = 1:num_stims
        % blanks
        input_mean((i-1) * 2 * num_stims + 2 * j - 1, :) = ...
            data(expt_struct.blanks{i,j}(1), :);
        % stims
        input_mean((i-1) * 2 * num_stims + 2 * j - 0, :) = ...
            data(expt_struct.stims{i,j}(1), :);
        % trial_ids
        trial_ids{i, j} = ...
            (i-1) * 2 * num_stims + 2 * j - 1 : ...
            (i-1) * 2 * num_stims + 2 * j;
    end
end
data = input_mean;
