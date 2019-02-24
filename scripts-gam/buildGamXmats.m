function [xmat, input_params] = buildGamXmats( ...
    dataset_name, net_arch, data, expt_struct, trial_ids, trial_avg)
% Build input matrices for gams
%
% INPUT:
%   dataset_name (str)
%   net_arch (struct)
%   data (T x num_predictors matrix)
%   expt_struct
%   trial_ids (T x 1 vector)
%   trial_avg (bool)
%
% OUTPUT:
%   xmat (cell array)
%   input_params (struct)

% create inputs
input_targ_list = [];
for sub = 1:length(net_arch)
    
    curr_targ = net_arch(sub).input_targ;
    
    % check to see if this input has already been processed
    if ~isempty(intersect(input_targ_list, curr_targ))
        continue
    else
        
        input_targ_list = [input_targ_list; curr_targ];
        
        % get raw input
        switch net_arch(sub).input_type

            case 'pop'
                
                input = data;
                
            case 'popavg'
                
                input = mean(data, 2);

            case 'pup'
                
                input = expt_struct.pup;
                
            case 'run'
                
                input = expt_struct.run;
                
            case 'stim'

                % get delta functions for stimulus id
                [input, stim_params] = buildStimMatrix( ...
                    dataset_name, expt_struct, data, ...
                    trial_ids, trial_avg);
                input = input{1};
                                           
            otherwise
                error('Invalid input type "%s"', net_arch(sub).input_type)                
        end
        
        % process input
        if trial_avg && dataset_name(1) == 'K' && ...
                ~strcmp(net_arch(sub).input_type, 'stim')
            
            % replace input values with mean over stim/blank indices
            input = getTrialMeanBonin(input, expt_struct, 'mean');

            % just use mean value from first bin of each stim
            [num_trials, num_stims] = size(expt_struct.stims);
            input_mean = zeros(2 * num_stims * num_trials, size(input, 2));
            for i = 1:num_trials
                for j = 1:num_stims
                    % blanks
                    input_mean((i-1) * 2 * num_stims + 2 * j - 1, :) = ...
                        input(expt_struct.blanks{i,j}(1), :);
                    % stims
                    input_mean((i-1) * 2 * num_stims + 2 * j - 0, :) = ...
                        input(expt_struct.stims{i,j}(1), :);
                end
            end
            if ~any(strcmp(net_arch(sub).input_type, {'pop', 'popavg'}))
                % pop/popavg already normalized
                input_mean = ...
                    bsxfun(@minus, input_mean, mean(input_mean, 1));
                input_mean = ...
                    bsxfun(@minus, input_mean, std(input_mean, [], 1));
            end
            input = input_mean;
            clear input_mean
        end
                
        input_params(curr_targ) = GAM.create_input_params( ...
            [net_arch(sub).input_lags, size(input, 2), 1], ... 
            'tent_spacing', net_arch(sub).input_tent_spacing);
        xmat{curr_targ} = GAM.create_time_embedding( ...
            input, ...
            input_params(curr_targ));
        clear input
        
        if strcmp(net_arch(sub).input_type, 'stim')
            input_params(curr_targ) = stim_params;
        end
        
    end
end

