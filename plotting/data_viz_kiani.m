figure

num_rows = 5;
num_iters = ceil(size(binned_spikes, 2) / num_rows);

stims = trial_info.coherence;
stim_types = unique(stims);
num_stims = length(stim_types);

stim_markers = NaN(num_stims, 2);
% mark beginning of first stim
stim_markers(1, 1) = 1;
for ns = 2:num_stims
    indx = find(stims==stim_types(ns), 1);
    % mark end of previous stim
    stim_markers(ns-1, 2) = indx - 1;
    % mark beginning of current stim
    stim_markers(ns, 1) = indx;
end
% mark end of last stim
stim_markers(end, 2) = length(stims);

indx = 1;
for iter = 1:num_iters
    for row = 1:num_rows
        subplot(num_rows, 1, row)
        cla
        % plot stimulus markers
        for ns = 1:num_stims
            rectangle('Position', ...
                [stim_markers(ns, 1), 0, ...
                stim_markers(ns, 2) - stim_markers(ns, 1), ...
                max(binned_spikes(:, indx))])
            hold on
        end
        % plot spikes
        plot(binned_spikes(:, indx));
        title(sprintf('Cell #%i', indx))
        indx = indx + 1;
    end
    pause
end