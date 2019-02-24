
%% plot single histogram

neuron = 69;
stim = 3;
indxs = trial_ids(:, stim);
indxs = [indxs{:}];

figure;
% histogram(binned_spikes(indxs, neuron))
plot(binned_spikes(indxs, neuron), '.')

%% cycle through raw histograms

num_rows = 5;
num_iters = ceil(size(binned_spikes, 2) / num_rows);



indx = 1;
for iter = 1:num_iters
    for row = 1:num_rows
        for stim = 1:12
            indxs = trial_ids(:, stim);
            indxs = [indxs{:}];
            subplot(num_rows, 12, (row - 1) * 12 + stim)
            cla
%             histogram(binned_spikes(indxs, indx));
            plot(binned_spikes(indxs, indx), '.');
            title(sprintf('Cell #%i', indx))
        end
        indx = indx + 1;
    end
    pause
end

%% 

monkey = 3;
neuron = 29;
stim = 5;
indxs = trial_ids(:, stim);
indxs = [indxs{:}];

d1 = datas{monkey}(indxs, neuron).^2;
p1 = pred{monkey, 1}(indxs, neuron).^2;
p1(:) = mean(p1);
p2 = pred{monkey, 2}(indxs, neuron).^2;

% figure;
% subplot(211)
% plot(d1, '.')
% hold on
% plot(p1, '.')
% 
% subplot(212)
% plot(d1, '.')
% hold on
% plot(p2, '.')

figure;
plot(d1, p1, '.')
hold on
plot(d1, p2, '.')

%% with model predictions loaded using figure_plotting (model_compare)

figure; 

ds = 3; % monkey number
num_neurons = size(datas{ds}, 2);

num_cols = 6;
num_rows = 2;

for neuron_indx = 89; %1:num_neurons
     
    for stim_num = 1:12
        for model = 1:num_models

            subplot(num_rows, num_cols, stim_num)
            cla
            
            indxs_stim = trial_ids(:, stim_num);
            indxs_stim = [indxs_stim{:}];

            stim_resp = pred{ds, 1}(indxs_stim, neuron_indx).^2;
            stim_resp = repmat(mean(stim_resp), 1, length(stim_resp));
            plot(datas{ds}(indxs_stim, neuron_indx).^2, ...
                stim_resp, '.');
            hold on
            plot(datas{ds}(indxs_stim, neuron_indx).^2, ...
                pred{ds, 2}(indxs_stim, neuron_indx).^2, '.');
            xlabel('Observed spike count')
            ylabel('Predicted firing rate')
            set(gca, 'FontSize', fontsize)
            set(gca, 'XColor', 'k')
            set(gca, 'YColor', 'k')
            box off
            legend boxoff
            xl = get(gca, 'xlim');
            ylim(xl);
            line([0, xl(2)], [0, xl(2)], 'color', 'k')

        end
    end
    subplot(num_rows, num_cols, 1)
    title(sprintf('Neuron %i', neuron_indx))
    subplot(num_rows, num_cols, 2)
    r2stim = mean(r2s{ds, 1}(neuron_indx, :));
    title(sprintf('R^2 stim = %4.3f', r2stim))
    subplot(num_rows, num_cols, 3)
    r2model = mean(r2s{ds, 2}(neuron_indx, :));
    title(sprintf('R^2 model = %4.3f', r2model))
    subplot(num_rows, num_cols, 4)
    title(sprintf('QI = %4.3f', (r2model - r2stim) / (1 - r2stim)))
    
    %pause
end


%% iso-QI plot (need to run figure_plotting model_scatter first)

figure;

for ds = 1:3
    r2_stim = mean(r2s{ds, 1}, 2);
    r2_model = mean(r2s{ds, 2}, 2);
    plot(r2_stim, r2_model, '.')
    hold on
end

r2stim = linspace(0, 1, 2);
qi_levels = [0, 0.25, 0.5, 0.75, 1];

for qi = qi_levels
    r2model = r2stim + qi * (1 - r2stim);
    plot(r2stim, r2model, 'k')
end
xlabel('Stimulus model R^2')
ylabel('Model R^2')
clean_plot

% highlight selected cells
cells = [9, 105, 109];

for i = cells
    plot(r2_stim(i), r2_model(i), '.k')
end

