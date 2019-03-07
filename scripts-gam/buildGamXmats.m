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

