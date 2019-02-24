function data = normalizeData(dataset_name, data)
% INPUT:
%   dataset_name (str): 
%   data (T x num_predictors matrix): predictor values
%
% OUTPUT:
%   data (T x num_predictors matrix): normalized predictor values

if dataset_name(1) == 'm' || dataset_name(1) == 'C' || ...
        dataset_name(1) == 'p' || dataset_name(1) == 'k'
    % spiking data
    % square root spike counts to stabilize variance
    data = sqrt(data);
elseif dataset_name(1) == 'K' || dataset_name(1) == 's'
    % 2p data
    % standardize data
    data = bsxfun(@rdivide, data, std(data, [], 1));
else
    error('dataset name "%s" does not have a normalizeData function', ...
        dataset_name)
end