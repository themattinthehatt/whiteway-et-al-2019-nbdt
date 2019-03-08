function data_struct = createSimData(num_neurons, rng_seed)
% This function simulates a population of neurons that are driven by a set
% of latent variables.
%
% INPUT:
%   num_neurons (int)
%   rng_seed (int)
%
% OUTPUT: 
%   data_struct: structure that contains information about the simlulated
%                data

% overall constants
num_lvs = 4;       % number of latent variables in data
firing_nl = 'lin'; % 'lin' | 'quad' | 'relu' - nl applied to final signal
T = 1000;          % total experiment duration (sec)
bin_size = 0.25;   % sec

num_bins = T / bin_size;

rng(rng_seed);

%% ********************** create data *************************************

% calculate firing rate activity
x = randn(num_bins, num_lvs);

w1 = randn(num_lvs, 10);
w2 = randn(10, num_neurons);

int_act = x * w1;
int_act(int_act < 0) = 0;

data_fr = int_act * w2;

% apply nonlinearity
switch firing_nl
    case 'lin'
        % firing_rate = firing_rate;
    case 'quad'
        data_fr = data_fr.^2;
    case 'relu'
        data_fr(data_fr < 0) = 0;
    case 'softplus'
        data_fr = log(1+exp(data_fr));
end

% create spiking data
data_spikes = poissrnd(data_fr);

%% ********************** organize data ***********************************

data_struct.meta.num_neurons = num_neurons;
data_struct.meta.rng_seed = rng_seed;
data_struct.meta.bin_size = bin_size;

data_struct.firing_nl = firing_nl;
data_struct.data_fr = data_fr;
data_struct.data_spikes = data_spikes;
