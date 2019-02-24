function [data_new, cell_ids] = filterData(data, expt_struct)
% get rid of bad cells; dataset dependent?
%
% INPUT:
%   data (T x num_predictors matrix): predictor values
%   expt_struct (struct array): field 'block' defines how filtering is
%       performed
%   cell_ids (vector)
%
% OUTPUT:
%   data_new (T x num_predictors matrix): cleaned data
%   cell_ids (vector): updated cell_ids vector to reflect cells that have
%       been removed from dataset

blocks = [expt_struct.block];
num_blocks = length(unique(blocks));

num_cells = size(data, 2);
removed = zeros(num_cells, 1);
medians = NaN(num_cells, num_blocks);

for block = 1:num_blocks
    
    data_block = data(blocks == block, :);
    
    % remove cells if no spike in block
    removed(sum(data_block, 1) == 0) = 1;
    
    % calculate median spike counts per block
    medians(:, block) = median(data_block, 1)';
    
end

% calculate quantiles of median spike counts over blocks
qs = NaN(num_cells, 3);
for nc = 1:num_cells
    qs(nc, :) = quantile(medians(nc, :), [0.25, 0.5, 0.75]);
end
q1 = qs(:, 1); q2 = qs(:, 2); q3 = qs(:, 3);
w = 1.5; % default used in matlab's boxplots; seems reasonable
outliers_lo = bsxfun(@lt, medians, q1 - w * (q3 - q1));
outliers_hi = bsxfun(@gt, medians, q3 + w * (q3 - q1));

% remove cells with outlier blocks on the high end
removed(sum(outliers_lo, 2) > 0) = 1;

% remove cells with outlier blocks on the low end
removed(sum(outliers_hi, 2) > 0) = 1;

% remove cells with low firing rates
removed(median(medians, 2) < 1) = 1;

% remove cells with large interquartile range
x = (q3 - q1) ./ q2;
removed(x > 1) = 1;

data_new = data(:, ~removed);
cell_ids = ~removed;
