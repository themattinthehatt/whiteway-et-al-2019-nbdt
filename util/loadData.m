function [expt_struct, binned_spikes, trial_ids, data_dir, results_dir] = ...
    loadData(dataset_name)
% INPUT:
%   dataset (str): see getDatasetStrings.m

[data_dir, results_dir] = configProjDirs(dataset_name);

if dataset_name(1) == 'v' || dataset_name(1) == 'p'
    % kohn data / kiani data
    filename = sprintf('%s.mat', dataset_name);
    file_loc = fullfile(data_dir, filename);
    try
        fprintf('Loading data...')
        load(file_loc, 'expt_struct', 'binned_spikes', 'trial_ids')
        fprintf('done!\n')
        expt_struct(1).stims = trial_ids;
        expt_struct(1).blanks = [];
    catch
        fprintf('\n')
        error('dataset %s does not exist', file_loc)
    end
else
    error('dataset name "%s" does not have a loadData function', ...
        dataset_name)
end

results_dir = fullfile(results_dir, dataset_name);
