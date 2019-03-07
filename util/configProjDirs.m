function [data_dir, results_dir] = configProjDirs(dataset_name)
% configure project directories
%
% INPUTS:
%   dataset_name (str): defined in getDatasetStrings
%
% OUTPUTS:
%   data_dir (str): location of data associated with `dataset_name`
%   results_dir (str): location of results associated with `dataset_name`

if strcmp(dataset_name, 'kohn')
    % kohn v1 data
    data_dir = '/home/mattw/data/kohn'; % this contains `pvc-11` directory
    results_dir = '/home/mattw/results/gam/';
elseif strcmp(dataset_name, 'kiani')
    % kiani pfc data
    data_dir = '/home/mattw/data/kiani';
    results_dir = '/home/mattw/results/gam/';
else
    error('Invalid dataset name "%s"', dataset_name)
end
