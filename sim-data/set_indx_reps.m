function indx_reps = set_indx_reps(num_pts, num_folds)

indx_reps = cell(num_folds, 1);

pts_per_fold = ceil(num_pts / num_folds);

for fold = 1:num_folds
    indxs_start = (fold - 1) * pts_per_fold + 1;
    indxs_end = fold * pts_per_fold;
    indx_reps{fold} = indxs_start:indxs_end;
end
