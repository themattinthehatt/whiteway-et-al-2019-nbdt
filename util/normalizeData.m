function data = normalizeData(dataset_name, data)
% INPUT:
%   dataset_name (str): 
%   data (T x num_predictors matrix): predictor values
%
% OUTPUT:
%   data (T x num_predictors matrix): normalized predictor values

if dataset_name(1) == 'v' || dataset_name(1) == 'p'
    % spiking data
    % square root spike counts to stabilize variance
    data = sqrt(data);
else
    error('dataset name "%s" does not have a normalizeData function', ...
        dataset_name)
end
