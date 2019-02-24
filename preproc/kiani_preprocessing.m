% preprocess data files from Kohn to look like Bonin data

[data_dir, ~] = configProjDirs('kiani');

% user variables
saving = 1;
overwrite = 0;
monkey = 3;

onset = 100; % ms
offset = 800; % ms

save_name = sprintf('km%i_all-stims_%04i-%04ims.mat', ...
    monkey, onset, offset);

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

%% cells to get rid of by eye (saved as kmxa_all-stims_0100-0800ms.mat)

% C42
% cells_to_remove = [1, 2, 3, 4, 8, 9, 11, 12, 13, 16, 19, 25, 27, 34, 39, 40, 41, 42, 44, 45, 46, 54, 56, 57, 61, 63, 65, 69, 70, 71, 73, 74, 77, 81, 83, 85, 86, 87, 90, 92, 93, 102, 103, 104, 109, 110, 111, 120, 121, 135, 137, 138, 141, 142, 143, 144, 145, 146, 147, 148, 149, 152, 155, 156, 158, 160, 161, 165, 166, 168, 177, 179, 185, 186, 187, 206, 208, 219];
% stims_to_include = {[0.025, 0.05, 0.10], [0.4, 0.8]};

% T33
% cells_to_remove = [2, 3, 5, 8, 9, 12, 13, 15, 19, 20, 23, 24, 28, 29, 30, 31, 33, 35, 36, 37, 43, 45, 46, 51, 52, 57, 58, 59, 60, 61, 62, 64, 66, 68, 70, 71, 74, 78, 82, 85, 87, 89, 90, 92, 93, 95, 96, 97, 98, 99, 100, 101, 109, 115, 118, 119, 120, 121, 124, 125, 126, 127, 128, 129, 130, 136, 138, 139, 151, 154, 155, 17, 159, 160, 165, 166, 168];
% stims_to_include = {[0.01, 0.02, 0.04], [0.08, 0.16, 0.32]};

% V07
% cells_to_remove = [1, 2, 3, 4, 5, 6, 16, 23, 24, 25, 30, 31, 32, 39, 44, 47, 54, 56, 57, 58, 59, 62, 63, 67, 68, 76, 80, 81, 83, 84, 88, 95, 96, 98, 99, 101, 102, 109, 110, 112, 113, 118, 119, 122, 123, 128, 132, 135, 136, 142, 145, 147, 148, 151, 152, 153, 154, 156, 157, 158, 160, 164, 165, 166, 167, 169, 175, 182, 183, 184, 185, 187, 189, 190, 191, 193, 196, 197, 199, 200, 201, 203, 204, 207, 208, 209, 210, 213, 214, 215, 216, 217, 218, 219];