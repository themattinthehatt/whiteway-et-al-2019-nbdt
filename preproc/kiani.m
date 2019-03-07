% preprocess data files from Kohn to look like Bonin data

[data_dir, ~] = configProjDirs('kiani');

% user variables
saving = 1;
overwrite = 0;
monkey = 1;

onset = 100; % ms
offset = 800; % ms

save_name = sprintf('pfc-%i_%04i-%04ims.mat', monkey, onset, offset);

%% ************************ load raw data *********************************

if monkey == 1
    monkey_name = 'C42';
elseif monkey == 2
    monkey_name = 'T33';
elseif monkey == 3
    monkey_name = 'V07';
else
    error('invalid monkey number %i', monkey)
end

filename1 = sprintf('%s.mat', monkey_name);
file_loc1 = fullfile(data_dir, 'raw', filename1);

fprintf('Loading spike data for monkey %s...', monkey_name)
load(file_loc1);
fprintf('done\n')

%% ********************** get binned spikes *******************************

% change ms -> s
% onset = onset / 1000; 
% offset = offset / 1000;

fprintf('Processing binned spikes...')

[num_trials, num_neurons] = size(spike_times);
stims = unique(trial_info.coherence);
num_stims = length(stims);
num_dirs = 2;
num_reps = -Inf;
for ns = 1:num_stims
    num_trs1 = sum(trial_info.coherence == stims(ns) & ...
        trial_info.correct_target == 1);
    num_trs2 = sum(trial_info.coherence == stims(ns) & ...
        trial_info.correct_target == 2);
    num_reps = max([num_reps, num_trs1, num_trs2]);
end

binned_spikes = NaN(num_trials, num_neurons);
trial_ids = cell(num_reps, num_stims * num_dirs);
expt_struct = struct([]);
rep_indx = ones(num_stims * num_dirs, 1);
for nt = 1:num_trials
    for nn = 1:num_neurons
        spikes = spike_times{nt, nn};
        binned_spikes(nt, nn) = sum(spikes > onset & spikes < offset);
    end
    ns = find(stims == trial_info.coherence(nt));
    nd = find([1, 2] == trial_info.correct_target(nt));
    np = 2 * ns + nd - 2;
    trial_ids{rep_indx(np), np} = nt;
    rep_indx(np) = rep_indx(np) + 1;
end

fprintf('done\n')

if saving
    filename = save_name;
    file_loc = fullfile(data_dir, filename);
    if ~exist(file_loc, 'file') || overwrite
        if exist(file_loc, 'file')
            warning('Overwriting %s...', file_loc)
        end
        fprintf('saving...')
        save(file_loc, 'binned_spikes', 'trial_ids', 'expt_struct');
        fprintf('done\n')
    elseif exist(file_loc, 'file') && ~overwrite
        fprintf('%s already exists; not overwriting\n', file_loc)
    end
end
