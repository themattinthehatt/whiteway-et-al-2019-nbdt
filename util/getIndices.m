function [indx_reps, trials_in_fold] = getIndices( ...
    num_folds, rng_seed, epoch_frames)
% splits data into folds; each fold includes a trial from each stimulus
% orientation
%
% INPUTS
%   num_folds		number of folds for xv
%   rng_seed		seed for random number generator to keep track of
%						training/xv indices
%	epoch_frames	num_trials x num_stims cell array of stim/blank indices
%
% OUTPUTS
%   indx_reps		[] x num_folds cell array of indices for use in 
%						training/xv

% pull out relevant info
[num_trials, num_stims] = size(epoch_frames);
trials_per_fold = floor(num_trials / num_folds);
indx_reps = cell(1, num_folds);
rng(rng_seed);
indx = randperm(num_trials);

num_leftover_trials = num_trials - num_folds * trials_per_fold;

trials_in_fold = cell(1,num_folds);
% distribute leftover trials into initial folds
for i = 1:num_folds
	if i <= num_leftover_trials
		trials_in_fold{i} = ...
            indx((i-1) * (trials_per_fold + 1) + ...
            (1 : (trials_per_fold + 1)));
	else
		trials_in_fold{i} = ...
            indx( ...
                num_leftover_trials * (trials_per_fold + 1) + ...
                (i-num_leftover_trials-1) * trials_per_fold + ...
                (1 : trials_per_fold));
	end
end

% populate indx_reps cell array
for i = 1:num_folds
	indx_list = [];
	for j = 1:length(trials_in_fold{i})
        for k = 1:num_stims
            indx_list = [indx_list, epoch_frames{trials_in_fold{i}(j), k}];
        end
% 		indx_list = [indx_list ...
% 			epoch_frames{trials_in_fold{i}(j), 1}(1) : ...
% 			epoch_frames{trials_in_fold{i}(j), end}(end)];
	end
	% add offset to all indices to account for excluded trials
	indx_reps{i} = indx_list;
end
