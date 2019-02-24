function [data_dir, results_dir] = configProjDirs(dataset_name)
% configure project directories
%
% INPUTS:
%   dataset_name (str): defined in getDatasetStrings

% machine that hosts data and results directories
% HOST = 'lip';
% 
% % get current system's name
% [~, hostname] = system('hostname');
% hostname = hostname(1:end-1); % odd space at end

% define data/results directories in HOST machine
if dataset_name(1) == 'm' || strcmp(dataset_name, 'v1') || ...
        strcmp(dataset_name, 'kohn')
    % kohn data
%     data_dir = '/home/mattw/data/ephys/v1/kohn';
    data_dir = '/media/mattw/Seagate Expansion Drive/data/ephys/v1/kohn';
%     results_dir = '/home/mattw/results/ephys/gam/';
    results_dir = '/media/mattw/Seagate Expansion Drive/results/ephys/gam/';
elseif dataset_name(1) == 'K' || strcmp(dataset_name, 'lgn2p') || ...
        strcmp(dataset_name, 'bonin') || dataset_name(1) == 's'
    % bonin data (awake/anest lgn 2p)
    data_dir = '/home/mattw/data/2p/v1/bonin_lab/tcaxons';
    results_dir = '/home/mattw/results/ephys/gam/';
elseif dataset_name(1) == 'C' || strcmp(dataset_name, 'lgnspike')
    % bonin data (awake lgn spiking)
    data_dir = '/home/mattw/data/ephys/lgn/lgnmov_example_datasets';
    results_dir = '/home/mattw/results/ephys/gam/';
elseif dataset_name(1) == 'p' || strcmp(dataset_name, 'pfc')
    % pfc data
    data_dir = '/home/mattw/data/ephys/pfc/saccade';
    results_dir = '/home/mattw/results/ephys/gam/';
elseif dataset_name(1) == 'k' || strcmp(dataset_name, 'pfc2') || ...
        strcmp(dataset_name, 'kiani')
    % kiani pfc data
%     data_dir = '/home/mattw/data/ephys/pfc/kiani';
    data_dir = '/media/mattw/Seagate Expansion Drive/data/ephys/pfc/kiani';
    results_dir = '/home/mattw/results/ephys/gam/';
else
    error('Invalid dataset name "%s"', dataset_name)
end
