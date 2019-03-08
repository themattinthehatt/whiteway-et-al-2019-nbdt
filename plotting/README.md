# Instructions for recreating paper figures

The following assumes that you have completed all steps for downloading the data and fitting the models located on the project homepage.

## Figure 1B

Run `sim-data/fit_loop.m` to generate simulated data, fit the models, and plot the results.

## Figure 2

**Fig. 2A, B**: `plotting/fig2_tuning_curves.m`

**Fig. 2C**: `plotting/fig2_iso_qi.m`

**Figure 2D**: `plotting/fig2_model_comparison.m`

## Figure 4

**Fig. 4A-E**: In the script `plotting/figure_plotting.m`, first choose the V1 datasets by setting `datasets = [1, 2, 3]` on line 3. Then, to choose this particular model comparison, on line 12 set `plot_type.model_scatter = 1` and set all other fields of `plot_type` to zero. 
To plot the scatter plots, on line 20 set `plot_scatter = 1`.
To plot the histogram insets, on line 20 set `plot_scatter = 0`. 
These plots will contain panels for each individual dataset, as well as summary panels that aggregate the results across all datasets.

**Fig. 4F**: `plotting/fig4_gam_vs_srlvm.m`

## Figure 5

**Fig. 5A**: In the script `plotting/figure_plotting.m`, first choose the PFC datasets by setting `datasets = [11, 12, 13]` on line 3. Then, to choose this particular model comparison, on line 13 set `plot_type.nonlinear_comp = 1` and set all other fields of `plot_type` to zero. Unfortunately this plotting function is quite rigid - you must plot data from all three monkeys at the same time, and must specify by hand (under the `if plot_type.nonlinear_comp` conditional on line 47) the best affine model for each monkey.

**Fig. 5B**: In the script `plotting/figure_plotting.m`, first choose the PFC datasets by setting `datasets = [11, 12, 13]` on line 3. Then, to choose this particular model comparison, on line 13 set `plot_type.extended_aff = 1` and set all other fields of `plot_type` to zero. The script is currently set up to plot up to 4 additive/multiplicative latent variables; to extend this, you must update the `model_strs` cell array defined on line 33, as well as the `add_rows` and `mul_rows` variables just below.

**Fig. 5C**: In the script `plotting/figure_plotting.m`, first choose the PFC datasets by setting `datasets = [11, 12, 13]` on line 3. Then, to choose this particular model comparison, on line 13 set `plot_type.nonlinear_comp2 = 1` and set all other fields of `plot_type` to zero. The script is currently set up to plot up to 4 additive/multiplicative latent variables; to extend this, you must update the `model_strs` cell array defined on line 33, as well as the `add_rows` and `mul_rows` variables just below.

## Figure 6

**Fig. 6A**: In the script `plotting/figure_plotting.m`, first choose the V1 datasets by setting `datasets = [1, 2, 3]` on line 3. Then, to choose this particular model comparison, on line 13 set `plot_type.extended_aff = 1` and set all other fields of `plot_type` to zero.  The script is currently set up to plot up to 4 additive/multiplicative latent variables; to extend this, you must update the `model_strs` cell array defined on line 33, as well as the `add_rows` and `mul_rows` variables just below.

**Fig. 6B**: In the script `plotting/figure_plotting.m`, first choose the V1 datasets by setting `datasets = [1, 2, 3]` on line 3. Then, to choose this particular model comparison, on line 13 set `plot_type.nonlinear_comp = 1` and set all other fields of `plot_type` to zero. Unfortunately this plotting function is quite rigid - you must plot data from all three monkeys at the same time, and must specify by hand (under the `if plot_type.nonlinear_comp` conditional on line 47) the best affine model for each monkey.
