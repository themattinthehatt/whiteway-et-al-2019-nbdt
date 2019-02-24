function [expt_struct, binned_spikes, trial_ids, data_dir, results_dir] = ...
    loadData(dataset_name)
% INPUTS:
%   dataset (str): see getDatasetStrings.m

[data_dir, results_dir] = configProjDirs(dataset_name);

if dataset_name(1) == 'm' || dataset_name(1) == 's' || ...
        dataset_name(1) == 'C' || dataset_name(1) == 'k'
    % kohn data / lgn spiking data / kiani data
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
elseif dataset_name(1) == 'K'
    % bonin data
    filename = sprintf('processed_data_%s.mat', dataset_name);
    file_loc = fullfile(data_dir, filename);
    try
        fprintf('Loading data...')
        load(file_loc)
        fprintf('done!\n')
        % make data look like standard data format
        binned_spikes = calciumdata.norm;
        trial_ids = stimulusdata.frames_visualstimuli.epochs;
        eyedata = fixPupInterp(dataset_name, eyedata);
        expt_struct.pup = eyedata.pupildiameterinterpolated;
        expt_struct.run = velocitydata.velocityinterpolated;
        expt_struct.stims = stimulusdata.frames_visualstimuli.stims;
        expt_struct.blanks = stimulusdata.frames_visualstimuli.blanks;
        expt_struct.fr = calciumdata.frame_rate;
    catch
        fprintf('\n')
        error('dataset %s does not exist', file_loc)
    end
elseif dataset_name(1) == 'p'
    % pfc data
    filename = sprintf('%s.mat', dataset_name);
    file_loc = fullfile(data_dir, filename);
    try
        fprintf('Loading data...')
        load(file_loc, 'expt_struct', 'binned_spikes', 'trial_ids')
        fprintf('done!\n')
        expt_struct(1).stims = trial_ids;
    catch
        fprintf('\n')
        error('dataset %s does not exist', file_loc)
    end
else
    error('dataset name "%s" does not have a loadData function', ...
        dataset_name)
end

results_dir = fullfile(results_dir, dataset_name);
