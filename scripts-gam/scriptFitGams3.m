function scriptFitGams3(dataset_nums, model)

%% ************************* setup ****************************************

% load/save variables
io_struct.saving = 1;           % 0 for none, 1 to save, 2 for extra info
io_struct.overwrite = 0;        % perform fits even if they already exist
io_struct.model_dir = '';       % sub-dir inside xv_dir for results
io_struct.sub_dir = 'pos_stim';         % sub-dir inside model_dir for results
io_struct.custom_ext = '';
io_struct.model_dir_stim = io_struct.model_dir;
io_struct.sub_dir_stim = '';
io_struct.custom_ext_stim = '';
io_struct.model_dir_model = '';
io_struct.sub_dir_model = '';
io_struct.custom_ext_model = '';

% data manipulation info
data_struct.normalize = 1;   
data_struct.fit_type = 'full';  % 'full' | 'loo'
data_struct.trial_avg = 1;      % 1 model activity avg'd over full trial
data_struct.data_type = 'fr';   % 'fr' | 'spikes' | '2p'
data_struct.num_folds = 10;     % number of folds to divide data into
data_struct.num_xvs = 10;       % number of folds to actually evaluate
data_struct.rng_seed = 0;       % seed for training/xv indices
data_struct.eval_only = 0;      % don't fit model; load/eval/resave
data_struct.pos_stim_mod = 1;   % only fit neurons with positive stim model

% model parameters
model_struct.fit_type = data_struct.fit_type;
model_struct.num_bfs = struct('add', 1, 'mult', 1);
model_struct.num_int_bfs = struct('add', 0, 'mult', 0);
model_struct.bfs_symm = struct('add', 1, 'mult', 0);
model_struct.reg_params = struct( ...
    'stim', struct('weights', 0, 'biases', 0), ...
    'add', struct('weights', 0, 'biases', 0), ... 
    'mult', struct('weights', 0, 'biases', 0));
model_struct.optim_params = struct( ...
    'max_iter', 15000, 'disp', 'off', 'deriv_check', 0);
model_struct.mult_nonlin = 'oneplus'; % 'exp' | 'oneplus'
model_struct.noise_dist = NaN;
model_struct.spiking_nl = NaN;
model_struct.fit_stim = 0;      % 1 to fit stim simult. w/ add models
model_struct.init_loo_w_full = 1; % 1 to init loo models with full models
                                  % assumes in same dir as stim models
                                  
% model_template types:
% ind
% add
% [add/mult/aff]_pop
% [add/mult/aff]_popavg
% [add/mult/aff]_pup
% [add/mult/aff]_run

%% ************************ model templates *******************************

% fit model types
if model == 0
    model_template.ind = 1;
elseif model < 11
    % additive models
    model_template.add_pop = 1;
    model_struct.num_bfs.add = model;
    model_struct.num_bfs.mult = 0;
    model_struct.num_int_bfs.add = 0;
    model_struct.num_int_bfs.mult = 0;
    io_struct.custom_ext = sprintf('%02i-%02i', ...
        model_struct.num_int_bfs.add, model);
elseif model < 21
    % multiplicative models
    model_template.mult_pop = 1;
    model_struct.num_bfs.add = 0;
    model_struct.num_bfs.mult = model - 10;
    model_struct.num_int_bfs.add = 0;
    model_struct.num_int_bfs.mult = 0;
    io_struct.custom_ext = sprintf('%02i-%02i', ...
        model_struct.num_int_bfs.mult, model - 10);
elseif model > 100
    % affine models
    model_template.aff_pop = 1;
   
    num_add = floor((model - 100) / 10);
    num_mult = model - 100 - num_add * 10;

    model_struct.num_bfs.add = num_add;
    model_struct.num_bfs.mult = num_mult;
    model_struct.num_int_bfs.add = 0;
    model_struct.num_int_bfs.mult = 0;
    io_struct.custom_ext = sprintf('%02i_%02i', num_add, num_mult);
end

% build model fit struct from model_templates
model_fit_struct = buildModelFitStruct( ...
    model_template, model_struct, io_struct);

%% ************************* fit models ***********************************

dataset_names = getDatasetStrings(dataset_nums);

% iterate through datasets
for ds = 1:length(dataset_names)
    
    % print update header
    fprintf('\n========== Dataset %s ==========\n', dataset_names{ds})

    data_struct.dataset_name = dataset_names{ds};
    
    % iterate through models
    for model_num = 1:length(model_fit_struct)
    
        % pull model data from model_fit_struct
        net_io = model_fit_struct(model_num).net_io;
        net_arch = model_fit_struct(model_num).net_arch;
        net_fit = model_fit_struct(model_num).net_fit;        
        
        % fit model type
        if strcmp(data_struct.fit_type, 'loo')
            error('Broken')
            fitGamsLoo(net_io, net_arch, net_fit, data_struct);
        else
            fitGams(net_io, net_arch, net_fit, data_struct);
        end
        
    end
    
end
