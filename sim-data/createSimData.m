function data_struct = createSimData(num_neurons, bin_size)
%     num_neurons, stim_gain, bin_size, dataset, filename)
stim_gain = 1;
dataset = 1;
% Creates synthetic data to for use with srlvm, multNIM and xNIM. 
% This script simulates a population of neurons that are driven by a 
% single stimulus signal s_t, which is modulated by a multiplicative gain 
% signal g_t. For a given neuron i, the firing rate r_t^i is calculated 
% according to 
%
% r_t^i = F[(1 + a^i * f_1(g_t)) * f_2(b_i * s_t) + c_i]
% 
% where
% r_t^i is the firing rate of neuron i at time t
% g_t is the gain term at time t
% a^i is the coupling of neuron i to the gain term
% f_1 is a nonlinearity
% s_t is the stimulus term at time t
% b^i is the coupling of neuron i to the stimulus term
% f_2 is a nonlinearity
% c^i is an offset
%
% INPUTS:
%   num_neurons (int)
%   stim_gain (str)
%   bin_size (int): in seconds
%   dataset
%   filename
% OUTPUTS: 
%   data_struct structure that contains information about the simlulated
%               data

plotting = 0;

% overall constants
% num_neurons = 50;
overall_int = 'mult';           % 'mult' | 'nl'
firing_nl = 'lin';             % 'lin' | 'quad' | 'relu' - nl applied to final gen signal

rng_seed = 0;
rng(rng_seed);
T = 1000;                       % total experiment duration (sec)
% bin_size = 0.050;               % sec
num_bins = T/bin_size;
filter_sigs = 0;                % 1 to filter stim/gain sigs

% stim signal constants
stim_freq_cutoff = 1;           % upper frequency cutoff for stim signal (Hz)
num_stim_sigs = 2;              % number of stimulus signals

% gain and stim signal constants
gain_freq_cutoff = 0.1;         % upper frequency cutoff for gain signal (Hz)

% predefined dataset types
% dataset = 31;
if dataset == 1
    % stim signal constants
    stim_nl = 'quad';           % 'lin' | 'quad' | 'relu' | 'sigmoid'
    norm_stim_coupling = 1;     % 1 to make stim couplings add to 1
    stim_sig_lin_comb = 1;      % 0(1) to combine stim sigs linearly after(before) nl stage
    stim_gain = 2;              % 'lin', 'quad', 'relu' ~ 2; 'sigmoid' ~ 10

    % gain and stim signal constants
    gain_nl = 'lin';            % 'lin' | 'quad' | 'relu' | 'exp' | 
                                % 'sigmoid' | 'none'
elseif dataset == 2
    % ** like dataset 1, but uses stim_sig_lin_comb = 0
elseif dataset == 3
    % ** like dataset 1, but uses 1+x gain term; also assumes that gain
    % term only acts as an inhibitory signal
    % stim signal constants
    stim_nl = 'relu';
    norm_stim_coupling = 1;     
    stim_sig_lin_comb = 1;     
    stim_gain = 6;          

    % gain and stim signal constants
    gain_nl = 'relu';          
elseif dataset == 4
    % ** like dataset 3, but uses stim_sig_lin_comb = 0;
    stim_nl = 'relu';
    norm_stim_coupling = 1;     
    stim_sig_lin_comb = 0;     
    stim_gain = 6;          

    % gain and stim signal constants
    gain_nl = 'relu'; 
elseif dataset == 5
    % ** like dataset 1, but with no gain term
    % stim signal constants
    stim_nl = 'relu';        
    norm_stim_coupling = 1;    
    stim_sig_lin_comb = 1;    
    stim_gain = 2;          

    % gain and stim signal constants
    gain_nl = 'none';         
elseif dataset == 6
    % ** like dataset 1, but with no gain term
    % stim signal constants
    stim_nl = 'relu';        
    norm_stim_coupling = 0;    
    stim_sig_lin_comb = 0;    
    stim_gain = 2;          

    % gain and stim signal constants
    gain_nl = 'none';         
elseif dataset == 7
    % ** like dataset 1, but uses 1 + sigmoid(x) gain term
    % stim signal constants
    stim_nl = 'relu';        
    norm_stim_coupling = 1;    
    stim_sig_lin_comb = 1;    
    stim_gain = 6;          

    % gain and stim signal constants
    gain_nl = 'sigmoid';
else
    % stim signal constants
    stim_nl = 'relu';
    norm_stim_coupling = 1;
    stim_sig_lin_comb = 1;
%     stim_gain = 2;

    % gain and stim signal constants
    gain_nl = 'relu';
end

% 2p constants
dt   = bin_size;            % time step size (sec)
tau1 = 1.5;                 % decay time constant (sec)
gam1 = 1-dt/tau1;           % x1(t) = gam1*x1(t-1)
tau2 = .4;                  % rise time constant (sec)
gam2 = 1-dt/tau2;           % x2(t) = gam2*x2(t-1)
snr  = 5;                   % signal to noise ratio


%% ********************** stimulus terms **********************************

% calculate coupling parameters for individual neurons
stim_coupling = cell(num_stim_sigs, 1);
for i = 1:num_stim_sigs
    if norm_stim_coupling
        stim_coupling{i} = -1 + 2*rand(num_neurons,1);
    else
        % bump up values for more activity
        stim_coupling{i} = 0.5 + 0.5*rand(num_neurons,1);
    end
end

% normalize stim coupling params if desired
if norm_stim_coupling
    coupling_vals = NaN(num_stim_sigs, 1);
    for n = 1:num_neurons
        % collect coupling vals for neuron n
        for i = 1:num_stim_sigs
            coupling_vals(i) = stim_coupling{i}(n);
        end
        % normalize
        coupling_vals = coupling_vals/sum(abs(coupling_vals));
        % redistribute coupling vals for neuron n
        for i = 1:num_stim_sigs
            stim_coupling{i}(n) = coupling_vals(i);
        end
    end
end

% make special neurons 
for i = 1:num_stim_sigs
    for j = 1:num_stim_sigs
        if i == j
            stim_coupling{j}(end-i+1) = 1;
        else
            stim_coupling{j}(end-i+1) = 0;
        end
    end
end

% initially set signals as random gaussian noise
stim_sig = cell(num_stim_sigs, 1);
for i = 1:num_stim_sigs
    stim_sig{i} = randn(T/bin_size,1);
end

% filter out high freqs in stim
if filter_sigs
    frame_rate = 1/bin_size; % Hz
    cutoff = stim_freq_cutoff / (frame_rate / 2);
    [b,a] = butter(2, cutoff, 'low');
    stim_sig_filt = cell(num_stim_sigs, 1);
    for i = 1:num_stim_sigs
        stim_sig_filt{i} = filter(b, a, stim_sig{i});
    end
else
    stim_sig_filt = stim_sig;
end

% stim sig
if stim_sig_lin_comb
    % stim_sig = f(a*s1 + b*s2 + ... )
    
    stim_sig_filt_nl = zeros(num_bins, num_neurons);
    
    % create linear combo of stim sigs
    for i = 1:num_stim_sigs
        stim_sig_filt_nl = stim_sig_filt_nl + ...
                           stim_sig_filt{i} * stim_coupling{i}';
    end
    
    % apply nonlinearity to linear combo
    switch stim_nl
        case 'lin'
            % stim_sig_filt_nl = stim_sig_filt_nl;
            % limit magnitude to 1 so it can act to both increase and decrease 
            % stim
            % stim_sig_filt_nl = stim_sig_filt_nl/max(abs(stim_sig_filt_nl));
        case 'quad'
            stim_sig_filt_nl = (stim_sig_filt_nl).^2;
        case 'relu'
            stim_sig_filt_nl(stim_sig_filt_nl < 0) = 0;
        case 'sigmoid'
            temp_sig = stim_sig_filt_nl;
            stim_sig_filt_nl = exp(temp_sig)./(1 + exp(temp_sig));
    end
    
else
    % stim_sig = f(a*s1) + f(b*s2) + ...
    
    stim_sig_filt_nl = zeros(num_bins, num_neurons);
    
    % create linear combo of stim sigs
    for i = 1:num_stim_sigs

        temp_sig = stim_sig_filt{i} * stim_coupling{i}';
        
        % apply nonlinearity to single stim
        switch stim_nl
            case 'lin'
                temp_sig_nl = temp_sig;
            case 'quad'
                temp_sig_nl = (temp_sig).^2;
            case 'relu'
                temp_sig_nl = temp_sig;
                temp_sig_nl(temp_sig_nl < 0) = 0;
        end
        
        % add f(a_i * s_i) to overall signal
        stim_sig_filt_nl = stim_sig_filt_nl + temp_sig_nl;
        
    end
    
end

stim_sig_filt_nl = stim_sig_filt_nl * stim_gain;

%% ********************** gain terms **************************************

% initially set signals as random gaussian noise
gain_sig = randn(T/bin_size,1);

% filter out high freqs in gain
if filter_sigs
    frame_rate = 1/bin_size; % Hz
    cutoff = gain_freq_cutoff / (frame_rate / 2);
    [b,a] = butter(2, cutoff, 'low');
    gain_sig_filt = filter(b, a, gain_sig);
else
    gain_sig_filt = gain_sig;
end

% gain sig
switch gain_nl
    case 'lin'
        % calculate coupling parameters for individual neurons
        gain_coupling = rand(num_neurons,1);
        % normalize
        gain_sig_filt = gain_sig_filt/max(abs(gain_sig_filt(:)));
        % pass through nl
        gain_sig_filt_nl = gain_sig_filt * gain_coupling';
        % limit magnitude to 1 so it can act to both increase and decrease 
        % gain
        gain_sig_filt_nl = gain_sig_filt_nl/max(abs(gain_sig_filt_nl(:)));
    case 'quad'
        % calculate coupling parameters for individual neurons
        gain_coupling = rand(num_neurons,1);
        % normalize
        gain_sig_filt = 1.0 * gain_sig_filt/std(gain_sig_filt);
        % pass through nl
        gain_sig_filt_nl = (gain_sig_filt * gain_coupling').^2;
    case 'relu'
        % calculate coupling parameters for individual neurons
        gain_coupling = -rand(num_neurons,1);
        % normalize
        gain_sig_filt = gain_sig_filt/std(gain_sig_filt);
        % pass through nl
        gain_sig_filt(gain_sig_filt < 0) = 0;
        % multiply by weights
        gain_sig_filt_nl = gain_sig_filt * gain_coupling';
        gain_sig_filt_nl(gain_sig_filt_nl < -1) = -1;
    case 'exp'
        % calculate coupling parameters for individual neurons
        gain_coupling = rand(num_neurons,1);
        % normalize
        gain_sig_filt = 1.5 * gain_sig_filt/std(gain_sig_filt);  % 2 is new for gam revisions
        % pass through nl
        gain_sig_filt_nl = -1 + exp(gain_sig_filt * gain_coupling');
    case 'sigmoid'
        % calculate coupling parameters for individual neurons
        gain_coupling = -rand(num_neurons,1);
        % normalize
        gain_sig_filt = 2 * gain_sig_filt/std(gain_sig_filt);
        % pass through nl
        gain_sig_filt = 1 ./ (1 + exp(-gain_sig_filt));
        % multiply by weights
        gain_sig_filt_nl = gain_sig_filt * gain_coupling';
    case 'none'
        % zero coupling parameters for individual neurons
        gain_coupling = zeros(num_neurons,1);
        % pass through nl
        gain_sig_filt_nl = gain_sig_filt * gain_coupling';
end

%% ********************** create data *************************************

% constant offsets to be added to generating signal
offset = zeros(num_neurons,1); %-0.25*rand(num_neurons,1);

% calculate activity
switch overall_int
    case 'mult'
        data_fr = (1 + gain_sig_filt_nl) .* stim_sig_filt_nl;
    case 'nl'
        x = gain_sig_filt_nl;
        y = stim_sig_filt_nl;
        data_fr = (x.^3).*y + cos(y).*sin(x);
end

% add offsets
data_fr = bsxfun(@plus, data_fr, offset');

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

% create 2p data
calcium_sig = zeros(num_bins, num_neurons);
for n = 1:num_neurons
    % decay signal
    x1 = filter(1, [1 -gam1], data_spikes(:,n));       
    % rise signal
    x2 = filter(1, [1 -gam2], data_spikes(:,n));       
    % combine the two
    calcium_sig(:,n) = x1 - x2;
end

% add noise with specified snr
sig_var = var(calcium_sig);
sig_var(sig_var == 0) = 1; % snr = 1 for empty channels if any
data_2p = calcium_sig + bsxfun(@times, ...
                               randn(num_bins,num_neurons), ...
                               sqrt(sig_var/snr));

%% ********************** organize data ***********************************

data_struct.meta.num_neurons = num_neurons;
data_struct.meta.rng_seed = rng_seed;
data_struct.meta.bin_size = bin_size;

data_struct.stim_freq_cutoff = stim_freq_cutoff;
data_struct.stim_coupling = stim_coupling;
data_struct.stim_nl = stim_nl;
data_struct.norm_stim_coupling = norm_stim_coupling;
data_struct.stim_sig_lin_combo = stim_sig_lin_comb;
data_struct.stim_sigs = stim_sig_filt;
data_struct.stim_sig_nl = stim_sig_filt_nl;

data_struct.gain_freq_cutoff = gain_freq_cutoff;
data_struct.gain_coupling = gain_coupling;
data_struct.gain_nl = gain_nl;
data_struct.gain_sig = gain_sig_filt;
data_struct.gain_sig_nl = gain_sig_filt_nl;

data_struct.firing_nl = firing_nl;
data_struct.data_fr = data_fr;
data_struct.data_spikes = data_spikes;
data_struct.data_2p = data_2p;

%% ********************** plot example neuron *****************************

if plotting

    neuron_num = 5;

    figure;
    
    total_subplots = 6;
    count = 1;
    
    % plot weighted stim sigs
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    temp_sigs = zeros(num_bins, num_stim_sigs);
    for i = 1:num_stim_sigs
        temp_sigs(:,i) = stim_sig_filt{i} * stim_coupling{i}(neuron_num);
    end
    temp_sigs = temp_sigs/max(abs(temp_sigs(:)));
    for i = 1:num_stim_sigs
        line([0, num_bins], [i, i], 'Color', [0.5, 0.5, 0.5]); hold on;
        plot(temp_sigs(:,i) + i); hold on;
    end
    title(sprintf('Weighted stim signals'))
    
    % plot overall stim_sig_filt_nl
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    plot(stim_sig_filt_nl(:,neuron_num));
    title(sprintf('Total stim signal'))

    % plot gain signal
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    plot(1 + gain_sig_filt_nl(:,neuron_num));
    title(sprintf('Gain signal; weight = %0.2f', gain_coupling(neuron_num)))

    % plot neuron's firing rate
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    plot(data_fr(:,neuron_num));
    title('Firing rate')

    % plot neuron's spiking activity
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    stem(data_spikes(:,neuron_num));
    title('Spikes')

    % plot neuron's 2p activity
    ax(count) = subplot(total_subplots, 1, count);
    count = count + 1;
    plot(calcium_sig(:,neuron_num), 'Color', 'k');
    hold on;
    plot(data_2p(:,neuron_num));
    title('2p')

    linkaxes(ax, 'x');

end

%% ********************** save data ***************************************

% if exist('filename', 'var')
% 
%     save(filename, 'data_struct');
% 
% end