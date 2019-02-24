function [net, r2s, fit_struct] = fitGamSeries( ...
    data, xmat, input_params, fits_stim, fit_init, ...
    indx_tr, indx_xv, net_arch, net_fit)
% Construct and fit a series of GAMs. Each GAM is trained with a different
% regularization value on the weights (hard-coded for now) using indx_tr,
% and the model with the lowest cost function calculated on indx_xv is
% returned
%
% INPUT:
%   data (T x num_outputs matrix): output values for network to predict
%   xmat (cell array): Each cell is a T x num_predictors matrix that serves
%       as input to the different subunits of the GAM
%   input_params (struct array): information about the predictors in the
%       xmat cell array that is passed to the GAM
%   fits_stim (array of NIMs): previously-fit stimulus models to speed up
%       model fitting
%   fit_init (GAM object): previously-fit GAM to initialize non-stim
%       weights
%   indx_tr (vector): training indices
%   indx_xv (vector): xv indices 
%   net_arch (struct): obtained from buildModelFitStruct.m
%   net_fit (struct): additional network details
%       noise_dist (str): see GAM class for options
%       spiking_nl (str): see GAM class for options
%       reg_vals (vector): reg_vals to fit models with; best is chosen
%
% OUTPUT:
%   net (GAM object): fitted model
%   r2s (vector): r2 values for each neuron on xv data
%   fit_struct (struct): detailed fitting info for model

num_cells = size(data, 2);

% initialize net
net0 = GAM( ...
    'noise_dist', net_fit.noise_dist, ... 
    'spiking_nl', net_fit.spiking_nl);
fit_layers = cell(0);

%% **************************** build model *******************************

% keep track of number of add/mult subunits
num_add = 0;
num_mult = 0;

for sub = 1:length(net_arch)

    if strcmp(net_arch(sub).type, 'add')
        num_add = num_add + 1;
    else
        num_mult = num_mult + 1;
    end
    
    % create subunit
    net0 = net0.create_subunit(net_arch(sub).type, ...
        net_arch(sub).layers, ...
        net_arch(sub).add_targs, ...
        net_arch(sub).input_targ, ...
        input_params(net_arch(sub).input_targ), ...
        'act_funcs', net_arch(sub).act_funcs, ...
        'init_params', 'gauss', ...
        'pretraining', 'pca-varimax');
    
    % update fit_layers; assumes we're only fitting 'add' layers
    if strcmp(net_arch(sub).type, 'add')
        fit_layers{end+1} = net_arch(sub).fit_layers;
    end
    
    % initialize weights with other model
    if net_fit.init_loo_w_full && ~isempty(fit_init)
        if strcmp(net_arch(sub).type, 'add') && ...
                ~strcmp(net_arch(sub).init, 'stim')
            for layer = 1:length(net0.add_subunits(num_add).layers)
                net0.add_subunits(num_add).layers(layer).weights = ...
                    fit_init.add_subunits(num_add).layers(layer).weights;
                net0.add_subunits(num_add).layers(layer).biases = ...
                    fit_init.add_subunits(num_add).layers(layer).biases;
                net0.add_subunits(num_add).pretraining = 'none';
            end
        elseif strcmp(net_arch(sub).type, 'mult') && ...
                ~strcmp(net_arch(sub).init, 'stim')
            for layer = 1:length(net0.mult_subunits(num_mult).layers)
                net0.add_subunits(num_add).layers(layer).weights = ...
                    fit_init.add_subunits(num_add).layers(layer).weights;
                net0.mult_subunits(num_mult).layers(layer).biases = ...
                    fit_init.mult_subunits(num_mult).layers(layer).biases;
                net0.mult_subunits(num_mult).pretraining = 'none';
            end
        end
    end

    % update weights if necessary
    if strcmp(net_arch(sub).init, 'stim')
        % initialize weights with stim filters if possible
        if ~isempty(fits_stim)
            filt_len = length(fits_stim(1).subunits.filtK);
            temp_weights = zeros(num_cells, filt_len);
            temp_offsets = zeros(num_cells, 1);
            for i = 1:num_cells
                % note: for only_sus case, this takes advantage of the 
                % fact that sus come before mus in the data struct
                temp_weights(i, :) = ...
                    fits_stim(i).subunits.filtK';
                temp_offsets(i) = fits_stim(i).spkNL.theta;
            end
            if strcmp(net_arch(sub).type, 'add')
                net0.add_subunits(end).layers(1).weights = temp_weights;
                net0.add_subunits(end).layers(1).biases = temp_offsets;
            else
                net0.mult_subunits(end).layers(1).weights = temp_weights;
                net0.mult_subunits(end).layers(1).biases = temp_offsets;
            end
            net0.biases = zeros(num_cells, 1);
        else
            % fit stim here
            layers = [size(xmat{1}, 2), num_cells];
            act_funcs = {'lin'};
            net_avg = RLVM( ...
                layers, 0, ...
                'noise_dist', net_fit.noise_dist, ...
                'act_funcs', act_funcs);
            % specify additional net_params
            net_avg = net_avg.set_reg_params('layer', ...
                'l2_weights', 0, ...
                'l2_biases', 0);
            net_avg = net_avg.set_optim_params( ...
                'display', 'off', ...
                'deriv_check', 0, ...
                'max_iter', 10000);
            % fit
            tic
            net_avg = net_avg.fit_model( ...
                'inputs', ...
                'pop_activity', data', ...
                'inputs', xmat{1}', ...
                'indx_tr', indx_tr);
            % initialize parameters
            temp_weights = net_avg.layers.weights;
            temp_biases = net_avg.layers.biases;
            net0.add_subunits(end).layers(1).weights = temp_weights;
            net0.add_subunits(end).layers(1).biases = temp_biases;
        end
    elseif strcmp(net_arch(sub).init, 'ones')
        % hold last layer of weights constant (goris/lin models)
        if strcmp(net_arch(sub).type, 'add')
            weight_size = size(net0.add_subunits(end).layers(end).weights);
            bias_size = size(net0.add_subunits(end).layers(end).biases);
            net0.add_subunits(end).layers(end).weights = ones(weight_size);
            net0.add_subunits(end).layers(end).biases = zeros(bias_size);
        else
            weight_size = size(net0.mult_subunits(end).layers(end).weights);
            bias_size = size(net0.mult_subunits(end).layers(end).biases);
            net0.mult_subunits(end).layers(1).weights = weight_size;
            net0.mult_subunits(end).layers(1).biases = bias_size;
        end
        net0.biases = zeros(num_cells, 1);    
    end

end % subunits
                   
% update optimization parameters
net0 = net0.set_optim_params( ...
    'max_iter', net_fit.max_iter, ...
    'display', net_fit.disp, ...
    'deriv_check', net_fit.deriv_check);


%% **************************** fit models ********************************

% fit networks with a range of regularization values
reg_type = 'l2';
if isfield(net_fit, 'reg_vals')
    reg_vals = net_fit.reg_vals;
else
    reg_vals = logspace(0, -5, 6);
end
if strcmp(reg_type, 'l1')
    reg_weights = 'l1_weights';
    reg_biases = 'l1_biases';
elseif strcmp(reg_type, 'l2')
    reg_weights = 'l2_weights';
    reg_biases = 'l2_biases';
end
if net_fit.init_loo_w_full && ~isempty(fit_init)
    reg_vals = fit_init.add_subunits(end).layers(1).reg_lambdas.l2_weights;
end
num_reg_vals = length(reg_vals);
nets(num_reg_vals, 1) = GAM();
costs = NaN(num_reg_vals, 1);

tic;
if ~(length(net_arch) == 1 && strcmp(net_arch.init, 'stim'))
    % if not the "independent" model

    for rv = 1:num_reg_vals

        nets(rv) = net0;

        % set reg val (for now overwrites stim sub reg vals)
        for sub = 1:length(nets(rv).add_subunits)
            nets(rv).add_subunits(sub) = ...
                nets(rv).add_subunits(sub).set_reg_params( ...
                    reg_weights, reg_vals(rv), ...
                    reg_biases, 0);
        end
        for sub = 1:length(nets(rv).mult_subunits)
            nets(rv).mult_subunits(sub) = ...
                nets(rv).mult_subunits(sub).set_reg_params( ...
                    reg_weights, reg_vals(rv), ...
                    reg_biases, 0);
        end

        % fit
        nets(rv) = nets(rv).fit_model( ... 
            'add_subunits', data, xmat, ...
            'indx_tr', indx_tr, ...
            'fit_layers', fit_layers);

        % test
        [mod_meas, ~, ~] = nets(rv).get_model_eval( ... 
            data, xmat, 'indx_tr', indx_xv);
        costs(rv) = mod_meas.cost_func;

    end
    
    % find best model
    [~, min_indx] = min(costs);
    net = nets(min_indx);
    
else
    net = net0;
    net.fit_history = struct('iters', 0, 'params_fit', 0);
end
time = toc;

% evaluate best model
[r2s, fit_struct] = evalGam(net, data, xmat, indx_tr, indx_xv);
fit_struct.time = time;

