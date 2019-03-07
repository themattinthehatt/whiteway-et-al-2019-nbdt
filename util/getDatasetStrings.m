function dataset_names = getDatasetStrings(dataset_nums)
% INPUT:
%   dataset_nums (vector of ints)
%
% OUTPUT:
%   dataset_names (cell array of strings)

dataset_names = cell(length(dataset_nums), 1);

count = 0;
for ds = dataset_nums
    count = count + 1;
        
    % v1 datasets
    if ds == 1
        dataset_names{count} = 'v1-1_0500-1000ms';
    elseif ds == 2
        dataset_names{count} = 'v1-2_0500-1000ms';
    elseif ds == 3
        dataset_names{count} = 'v1-3_0500-1000ms';
                   
    % kiani pfc datasets
    elseif ds == 11
        dataset_names{count} = 'pfc-1_0100-0800ms';
    elseif ds == 12
        dataset_names{count} = 'pfc-2_0100-0800ms';
    elseif ds == 13
        dataset_names{count} = 'pfc-3_0100-0800ms';
        
    else
        error('Invalid dataset number "%g"', ds)
    end
    
end
    