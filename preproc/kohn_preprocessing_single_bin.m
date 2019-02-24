% preprocess data files from Kohn to look like Bonin data

[data_dir, ~] = configProjDirs('kohn');

% user variables
saving = 1;
overwrite = 0;
monkey = 3;

onset = 160; % ms
offset = 260; % ms

save_name = sprintf('monkey%i_all-stims_%04i-%04ims', ...
    monkey, onset, offset);

%% ************************ load raw data *********************************

filename1 = sprintf('data_monkey%i_gratings.mat', monkey);
file_loc1 = fullfile(data_dir, 'pvc-11', 'data_and_scripts', ...
    'spikes_gratings', filename1);

fprintf('Loading spike data for monkey %i...', monkey)
load(file_loc1);
fprintf('done\n')

%% ********************** get binned spikes *******************************

% change ms -> s
onset = onset / 1000; 
offset = offset / 1000;

fprintf('Processing binned spikes...')

[num_neurons, num_stims, num_reps] = size(data.EVENTS);
num_trials = num_stims * num_reps;

binned_spikes = NaN(num_trials, num_neurons);
trial_ids = cell(num_reps, num_stims);
expt_struct = struct([]);
indx = 0;
for nr = 1:num_reps
    for ns = 1:num_stims
        indx = indx + 1;
        for nn = 1:num_neurons  
            spikes = data.EVENTS{nn, ns, nr};
            binned_spikes(indx, nn) = sum(spikes > onset & spikes < offset);
        end
        trial_ids{nr, ns} = indx;
    end
end

fprintf('done\n')

if saving
    fprintf('saving...')
    filename = save_name;
    file_loc = fullfile(data_dir, filename);
    if ~exist(file_loc, 'file') || overwrite
        if exist(file_loc, 'file')
            warning('Overwriting %s...', file_loc)
        end
        save(file_loc, 'binned_spikes', 'trial_ids', 'expt_struct');
    end
    fprintf('done\n')
end
