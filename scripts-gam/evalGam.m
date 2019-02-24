function [r2s, fit_struct] = evalGam(net, data, xmat, indx_tr, indx_xv)
%
% INPUT:
%   data (T x num_outputs matrix): output values for network to predict
%   xmat (cell array): Each cell is a T x num_predictors matrix that serves
%       as input to the different subunits of the GAM
%   indx_tr (vector): training indices
%   indx_xv (vector): xv indices 
%
% OUTPUT:
%   r2s (vector): r2 values for each neuron on xv data
%   fit_struct (struct): detailed fitting info for model

num_neurons = net.num_neurons;

% evaluate full model
mod_meas_tr = net.get_model_eval(data, xmat, 'indx_tr', indx_tr);
mod_meas_xv = net.get_model_eval(data, xmat, 'indx_tr', indx_xv);

% update fit_struct
fit_struct.iters = net.fit_history(end).iters;
fit_struct.params = net.fit_history(end).params_fit;

fit_struct.tr.r2s = mod_meas_tr.r2s;
fit_struct.tr.r2_mean = mean(mod_meas_tr.r2s);
fit_struct.tr.r2_median = median(mod_meas_tr.r2s);
fit_struct.tr.ll = mod_meas_tr.LL;
fit_struct.tr.llnull = mod_meas_tr.LLnull;
fit_struct.tr.cost = mod_meas_tr.cost_func;

fit_struct.xv.r2s = mod_meas_xv.r2s;
fit_struct.xv.r2_mean = mean(mod_meas_xv.r2s);
fit_struct.xv.r2_median = median(mod_meas_xv.r2s);
fit_struct.xv.ll = mod_meas_xv.LL;
fit_struct.xv.llnull = mod_meas_xv.LLnull;
fit_struct.xv.cost = mod_meas_xv.cost_func;

% perform leave-one-out cross-validation if any input matrices are same
% size as the number of neurons
fit_struct.xv_full = fit_struct.xv;

perform_loo = 0;
for i = 1:length(xmat)
    if size(xmat{i}, 2) == num_neurons
        perform_loo = 1;
    end
end

if perform_loo == 1
    
    % get loo r2s
    r2s_temp = NaN(num_neurons, 1);
    lls_temp = NaN(num_neurons, 1);
    llnulls_temp = NaN(num_neurons, 1);
    costs_temp = NaN(num_neurons, 1);
    
    for nn = 1:num_neurons
        xmat_temp = xmat;
        for i = 1:length(xmat)
            if size(xmat{i}, 2) == num_neurons
%                 xmat_temp{i}(:, nn) = 0;
                xmat_temp{i}(:, nn) = mean(xmat_temp{i}(:, nn));
            end
        end
        mod_meas_xv = net.get_model_eval( ...
            data, xmat_temp, 'indx_tr', indx_xv);
        r2s_temp(nn) = mod_meas_xv.r2s(nn);
        lls_temp(nn) = mod_meas_xv.LL(nn);
        llnulls_temp(nn) = mod_meas_xv.LLnull(nn);
        costs_temp(nn) = mod_meas_xv.cost_func;
    end
    
    % update fit_struct
    fit_struct.xv.r2s = r2s_temp;
    fit_struct.xv.r2_mean = mean(r2s_temp);
    fit_struct.xv.r2_median = median(r2s_temp);
    fit_struct.xv.ll = lls_temp;
    fit_struct.xv.llnull = llnulls_temp;
    fit_struct.xv.cost = costs_temp;
    
end

r2s = fit_struct.xv.r2s;


