%% create data
num_neurons = 50;
num_folds = 10;
num_xvs = 10;

%% define model

% load/save variables
io_struct.saving = 0;           % 0 for none, 1 to save, 2 for extra info
io_struct.overwrite = 0;        % perform fits even if they already exist
io_struct.model_dir = '';       % sub-dir inside xv_dir for results
io_struct.sub_dir = '';         % sub-dir inside model_dir for results
io_struct.custom_ext = '';
io_struct.model_dir_stim = '';
io_struct.sub_dir_stim = '';
io_struct.custom_ext_stim = '';
io_struct.model_dir_model = '';
io_struct.sub_dir_model = '';
io_struct.custom_ext_model = '';

% model parameters
model_struct.fit_type = 'fr';
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
         
%% fit models

model_template.add = 1;
bf_vals = [1, 2, 3, 4, 5, 6];
int_bf_vals = [0, 10];

num_bf_vals = length(bf_vals);
num_int_bf_vals = length(int_bf_vals);

% save model outputs
fits_gam = cell(num_int_bf_vals, num_bf_vals, num_xvs);
meas_gam.r2s = cell(num_int_bf_vals, num_xvs);
meas_gam.fit_struct = cell(num_int_bf_vals, num_xvs);

% set up loop counter
loop_counter = 0;
loop_start = 1;
loop_end = num_xvs * num_bf_vals * num_int_bf_vals;
    
% loop through fits
for nxv = 1:num_xvs

    % build data
    data_struct = createSimData2(num_neurons, nxv); % good fig is Data3
    data = data_struct.data_fr;
    xmat{1} = data;
    input_params(1) = GAM.create_input_params([1, num_neurons, 1]);
    indx_reps = set_indx_reps(size(data, 1), num_folds);
    
    % determine training/xv indices
    indx_tr = [indx_reps{setdiff(1:num_folds, nxv)}];
    indx_tr = sort(indx_tr(:));
    indx_xv = sort(indx_reps{nxv});
    
    for ibf = 1:num_int_bf_vals
        for bf = 1:num_bf_vals

            % print updates
            loop_counter = loop_counter + 1;
            msg = sprintf('Fitting model %02g of %02g', loop_counter, loop_end);
            if loop_counter ~= loop_start
                fprintf([repmat('\b', 1, length(msg)), msg])
            else
                fprintf(msg)
            end
            
            model_struct.num_bfs.add = bf_vals(bf);
            model_struct.num_int_bfs.add = int_bf_vals(ibf);

            model_fit_struct = buildModelFitStruct( ...
                model_template, model_struct, io_struct);

            % pull model data from model_fit_struct
            net_io = model_fit_struct.net_io;
            net_arch = model_fit_struct.net_arch;
            net_fit = model_fit_struct.net_fit;
            net_fit.noise_dist = 'gauss';
            net_fit.spiking_nl = 'lin';
            net_fit.reg_vals = [1e-5];
            for i = 1:length(net_arch)
               for j = 1:length(net_arch(i).layers)
                   if net_arch(i).layers(j) == -1
                       net_arch(i).layers(j) = num_neurons;
                   end
               end
            end
            % lvm -> rlvm
            if model_struct.num_int_bfs.add == 0
                net_arch.act_funcs{1} = 'relu';
            end          

            % fit model
            [net, r2s, fit_struct] = fitGamSeries( ...
                data, xmat, input_params, [], [], ...
                indx_tr, indx_xv, net_arch, net_fit);

            % store results
            fits_gam{ibf, bf, nxv} = net;
            meas_gam.r2s{ibf, bf, nxv} = r2s;
            meas_gam.fit_struct{ibf, bf, nxv} = fit_struct;

        end % num_xvs
    end % bf_vals
end % int_bf_vals
fprintf('\n\n')

%% plot model r2s

r2s = NaN(num_int_bf_vals, num_bf_vals, num_xvs);

% median r2s over neurons
for ibf = 1:num_int_bf_vals
    for bf = 1:num_bf_vals
        for nxv = 1:num_xvs
            r2s(ibf, bf, nxv) = median(meas_gam.r2s{ibf, bf, nxv});
        end
    end
end

figure;
mns = mean(r2s, 3);
stds = std(r2s, [], 3) / sqrt(num_xvs);
% mns = r2s;
% stds = zeros(size(r2s));
for ibf = 1:num_int_bf_vals
    x = bf_vals(:);
    y = mns(ibf, :);
    e = stds(ibf, :);
    errorbar(x(:), y(:), e(:))
    hold on;
end
        
legend({'RLVM', 'SRLVM'})
