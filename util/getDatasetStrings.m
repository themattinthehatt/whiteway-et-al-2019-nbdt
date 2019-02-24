function dataset_names = getDatasetStrings(dataset_nums)
% INPUTS:
%   dataset_nums (vector of ints)
%
% OUTPUTS:
%   dataset_names (cell array of strings)
%
% DATASETS
%   lgn dataset: (2p/mouse; karolina socha and vincent bonin)
%   v1 datasets: (ephys/monkey; matthew smith and adam kohn)
%   v1 datasets: (ephys/monkey; adrian bondy and bruce cumming)
%       >= 
dataset_names = cell(length(dataset_nums), 1);

count = 0;
for ds = dataset_nums
    count = count + 1;
    
    % lgn 2p datasets
    if ds == 1
        dataset_names{count} = 'KS093_run01';
    elseif ds == 2
        dataset_names{count} = 'KS093_run03';
    elseif ds == 3
        dataset_names{count} = 'KS103_run01';
    elseif ds == 4
        dataset_names{count} = 'KS103_run03';
    elseif ds == 5 % no pup diam
        dataset_names{count} = 'KS164_run03_anest';
    elseif ds == 6
        dataset_names{count} = 'KS164_run03_awake';
    elseif ds == 7 % pup diam not good all the way through
        dataset_names{count} = 'KS166_run03_anest';
    elseif ds == 8
        dataset_names{count} = 'KS166_run03_awake';
    elseif ds == 9 % pup diam has a single strange spike towards end
        dataset_names{count} = 'KS167_run03_anest';
    elseif ds == 10
        dataset_names{count} = 'KS167_run03_awake';
    elseif ds == 11 % could use a small bit of cleaning up; otherwise ok
        dataset_names{count} = 'KS173_run03_anest';
    elseif ds == 12
        dataset_names{count} = 'KS173_run03_awake';
    elseif ds == 13 % strange looking but might be ok
        dataset_names{count} = 'KS174_run03_anest';
    elseif ds == 14
        dataset_names{count} = 'KS174_run03_awake';
        
    % lgn 2p datasets, stim only
    elseif ds == 21
        dataset_names{count} = 'stim_data_KS093_run01';
    elseif ds == 22
        dataset_names{count} = 'stim_data_KS093_run03';
    elseif ds == 23
        dataset_names{count} = 'stim_data_KS103_run01';
    elseif ds == 24
        dataset_names{count} = 'stim_data_KS103_run03';
    elseif ds == 25
        dataset_names{count} = 'stim_data_KS164_run03_anest'; % 7 reps
    elseif ds == 26
        dataset_names{count} = 'stim_data_KS164_run03_awake'; % 7 reps
    elseif ds == 27
        dataset_names{count} = 'stim_data_KS166_run03_anest';
    elseif ds == 28
        dataset_names{count} = 'stim_data_KS166_run03_awake';
    elseif ds == 29
        dataset_names{count} = 'stim_data_KS167_run03_anest'; % 7 reps
    elseif ds == 30
        dataset_names{count} = 'stim_data_KS167_run03_awake'; % 7 reps
    elseif ds == 31
        dataset_names{count} = 'stim_data_KS173_run03_anest';
    elseif ds == 32
        dataset_names{count} = 'stim_data_KS173_run03_awake';
    elseif ds == 33
        dataset_names{count} = 'stim_data_KS174_run03_anest';
    elseif ds == 34
        dataset_names{count} = 'stim_data_KS174_run03_awake';
        
    % v1 datasets
    elseif ds == 100
        dataset_names{count} = 'monkey1_all-stims_0160-0260ms';
    elseif ds == 101
        dataset_names{count} = 'monkey1_all-stims_0500-1000ms';
    elseif ds == 102
        dataset_names{count} = 'monkey1_all-stims_0060-1260ms';
    elseif ds == 103 % created to match mk4 in fr and stim R2s
        dataset_names{count} = 'monkey1_all-stims_0060-1260ms_sub-neurons';
    elseif ds == 104 % created to match mk4 in fr, stim R2s and trials
        dataset_names{count} = 'monkey1_all-stims_0060-1260ms_sub-neurons-trials';
    elseif ds == 105
        dataset_names{count} = 'monkey1_all-stims_0060-1260ms_100ms-bins';
        
    elseif ds == 110
        dataset_names{count} = 'monkey2_all-stims_0160-0260ms';
    elseif ds == 111
        dataset_names{count} = 'monkey2_all-stims_0500-1000ms';
    elseif ds == 112
        dataset_names{count} = 'monkey2_all-stims_0060-1260ms';
    elseif ds == 113 % created to match mk4 in fr and stim R2s
        dataset_names{count} = 'monkey2_all-stims_0060-1260ms_sub-neurons';
    elseif ds == 114 % created to match mk4 in fr, stim R2s and trials
        dataset_names{count} = 'monkey2_all-stims_0060-1260ms_sub-neurons-trials';
    elseif ds == 115
        dataset_names{count} = 'monkey2_all-stims_0060-1260ms_100ms-bins';
        
    elseif ds == 120
        dataset_names{count} = 'monkey3_all-stims_0160-0260ms';
    elseif ds == 121
        dataset_names{count} = 'monkey3_all-stims_0500-1000ms';
    elseif ds == 122
        dataset_names{count} = 'monkey3_all-stims_0060-1260ms';
    elseif ds == 123 % created to match mk4 in fr and stim R2s
        dataset_names{count} = 'monkey3_all-stims_0060-1260ms_sub-neurons';
    elseif ds == 124 % created to match mk4 in fr, stim R2s and trials
        dataset_names{count} = 'monkey3_all-stims_0060-1260ms_sub-neurons-trials';
    elseif ds == 125
        dataset_names{count} = 'monkey3_all-stims_0060-1260ms_100ms-bins';
        
    elseif ds == 130
        dataset_names{count} = 'monkey4_all-stims_0160-0260ms';
    elseif ds == 131
        dataset_names{count} = 'monkey4_all-stims_0500-1000ms';
    elseif ds == 132
        dataset_names{count} = 'monkey4_all-stims_0060-1260ms';
    elseif ds == 133
        dataset_names{count} = 'monkey4_all-stims_0050-0350ms';
    elseif ds == 135
        dataset_names{count} = 'monkey4_all-stims_0060-1260ms_100ms-bins';
        
    % lgn spiking datasets
    elseif ds == 190 % created from CA021 to match CA066 in fr and stim R2s
        dataset_names{count} = 'CA021_all-stims_0000-2000ms_sub-neurons';
    elseif ds == 191 % created from CA021 to match CA066 in fr and stim R2s
        dataset_names{count} = 'CA021_all-stims_0050-0350ms_sub-neurons';

    elseif ds == 200
        dataset_names{count} = 'CA021_all-stims_0000-2000ms';
    elseif ds == 201
        dataset_names{count} = 'CA021_all-stims_0050-0350ms';
    
    elseif ds == 210
        dataset_names{count} = 'CA062_all-stims_0000-2000ms';

    elseif ds == 220
        dataset_names{count} = 'CA063_all-stims_0000-2000ms';

    elseif ds == 230
        dataset_names{count} = 'CA064_all-stims_0000-2000ms';

    elseif ds == 240
        dataset_names{count} = 'CA066_all-stims_0000-2000ms';
    elseif ds == 211
        dataset_names{count} = 'CA066_all-stims_0050-0350ms';
            
    % bruno pfc datasets
    elseif ds == 300
        dataset_names{count} = 'pfc-voltaire-spatial-500';
    elseif ds == 301
        dataset_names{count} = 'pfc-waldo-spatial-500';
        
    % kiani pfc datasets
    elseif ds == 400
        dataset_names{count} = 'km1_all-stims_0100-0800ms';
    elseif ds == 401
        dataset_names{count} = 'km2_all-stims_0100-0800ms';
    elseif ds == 402
        dataset_names{count} = 'km3_all-stims_0100-0800ms';
        
    elseif ds == 410
        dataset_names{count} = 'km1a_all-stims_0100-0800ms';
    elseif ds == 411
        dataset_names{count} = 'km2a_all-stims_0100-0800ms';
    elseif ds == 412
        dataset_names{count} = 'km3a_all-stims_0100-0800ms';
        
    else
        error('Invalid dataset number "%g"', ds)
    end
    
end
    