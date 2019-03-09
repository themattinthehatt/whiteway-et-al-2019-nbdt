# Characterizing the nonlinear structure of shared variability in cortical neuron populations using latent variable models

This repository contains code for replicating the analyses carried out by Whiteway et al. in the paper _Characterizing the nonlinear structure of shared variability in cortical neuron populations using latent variable models_, available [here](https://www.biorxiv.org/content/biorxiv/early/2018/09/04/407858.full.pdf). Instructions are located below.

## Step 1: Acquire the data

We analyzed two publicly available datasets. 

**V1 dataset**. We analyzed electrophysiology data from the Kohn Lab, which has been made publicly available by CRCNS at http://dx.doi.org/10.6080/K0NC5Z4X. Spiking activity was recorded with a Utah array in primary visual cortex from three anesthetized macaques, in response to full-contrast drifting gratings with 12 equally-spaced directions, presented for 1280 ms (200 repeats). Full details can be found in the original paper [here](https://www.ncbi.nlm.nih.gov/pubmed/19036953). If you have not accessed data from CRCNS before you will have to first request access (as detailed [here](http://crcns.org/download)). Place the `pvc-11` directory containing the raw data anywhere in your directory; we'll specify the location later in a Matlab configuration file.

**PFC dataset**. We also analyzed electrophysiology data from the Kiani Lab, which has been made publicly available at http://www.cns.nyu.edu/kianilab/Datasets.html (population responses of pre-arcuate gyrus). Spiking activity was recorded with a Utah array in area 8Ar of the prearcuate gyrus from three macaques as they performed a direction discrimination task. On each trial the monkey was presented with a random dot motion stimulus for 800 ms, and after a variable-length delay period the monkey
reported the perceived direction of motion by saccading to a target in the corresponding direction. The coherence of the dots and their direction of motion varied randomly from trial to trial. As before, place the data directory anywhere in your directory.

## Step 2: Initialize the project

Before preprocessing or analyzing the data we'll need to tell Matlab where that data is. First download or pull this project directory onto your local machine, and add it to your Matlab path. Then, in the `util/configProjDirs.m` file, change the current paths to reflect where you placed the V1 and PFC datasets, as well as paths to where the analysis results will be stored.

## Step 3: Preprocess the data

We're going to put data from both datasets into the same data structure. There will be a matrix called `binned_spikes` with size `num_trials x num_neurons`. There will be an additional variable called `trial_ids` that is a `num_repeats x num_stims` cell array, where the `i, j` entry is the index along the first axis of `binned_spikes` for the `i`th repeat of the `j`th stimulus. 

**V1 dataset**. Open `preproc/kohn.m` and run this function three times, using `monkey = 1`, `monkey = 2`, and `monkey = 3`.  Each run will save a file in the V1 data directory specified in `util/configProjDirs.m` called `v1-X1_X2-X3ms.mat` where `X1` is the monkey number, `X2` is the onset time in ms, and `X3` is the offset time in ms (in the paper `X2 = 500` and `X3 = 1000`). 

**PFC dataset**. Open `preproc/kiani.m` and run this function three times, again using `monkey = 1`, `monkey = 2`, and `monkey = 3`.  Each run will save a file in the PFC data directory specified in `util/configProjDirs.m` called `pfc-X1_X2-X3ms.mat` where `X1` is the monkey number, `X2` is the onset time in ms, and `X3` is the offset time in ms (in the paper `X2 = 100` and `X3 = 800`). 

## A note about the data and models

**Data**. Each of the datasets in this analysis is identified by a unique integer, which is defined in `util/getDatasetStrings.m`.  This makes the entire analysis pipeline easily applicable to new datasets, as long as they are in the format specified above and are entered into this function.

**Models**. All of the code from this point on relies on the [GAM toolbox](https://github.com/themattinthehatt/gam), which should run out of the box. You will also need to download or pull this project directory onto your local machine, and add it to your Matlab path. Additionally, the fitting of the stimulus models uses the [NIM toolbox](https://github.com/dbutts/NIMclass), which you will need to download or pull onto your local machine, and add to your Matlab path. 
In the paper we used 10-fold cross-validation; to make model fitting faster for anyone interested in using this code the default has been set to 5-fold, which can be changed in the boiler plate code at the top of the fitting scripts (e.g. `scripts-gam/scriptFitGAMs.m`) in the `data_struct` struct (`num_folds` corresponds to number of cross-validation folds to break data into, `num_xvs` corresponds to actual number of folds to evaluate).

## Step 4: Fit (S)RLVM models

The first analysis that we perform in the paper is fitting a series of autoencoders to the data. The highest-level Matlab function to do so is `scripts-gam/scriptFitSRLVMs.m`. The inputs to this function are the dataset number(s) (defined in `util/getDatasetStrings.m`) and the model number. Like the datasets, each model is defined by its own integer - in this case 1-10 defines a single hidden layer autoencoder with the corresponding number of units in the hidden layer. 11-20 defines a three hidden layer autoencoder with 15-X-15 units in the three layers, where X is represented by the model number minus 10. There are many functions called by `scripts-gam/scriptFitSRLVMs.m`, which I will briefly detail below; in the event you want to use these functions and find their structure confusing, please do not hesitate to contact me.

- `scripts-gam/buildModelFitStruct.m`:  defines model structures used in the paper in a format that the `gam` library can use, including the RLVM, SRLVM, GAM, and Extended GAM, as well as previously published models like the additive model (Ecker et al. 2014), multiplicative model (Goris et al. 2014) and affine model (Lin et al. 2015; Arandia-Romero et al. 2016).
- `scripts-gam/fitGams.m`: another high-level function that takes care of loading data, performing cross-validation, and saving the results.
- `scripts-gam/buildGamXmats.m`:  constructs input matrices for the different modules of the models; in the models described here this only includes the stimulus or population activity, but this function can be expanded to include other predictors such as pupil diameter, run speed, etc.
- `util/getIndices.m`:  splits data into cross-validation folds; each fold includes a trial from each stimulus condition.
- `scripts-gam/fitGamSeries.m`:  for a given set of training/testing data, this function fits a series of models using a range of L2 regularization values on model weights (hard-coded on line 175, or alternatively can be specified in the `net_fit` struct defined in `scripts-gam/buildModelFitStruct.m`).

## Alternate Step 4: Fit (S)RLVM models faster

The analyses in this paper rely on fitting and comparing many models. Though one could write yet another Matlab function that loops over calls to `scripts-gam/scriptFitSRLVMs.m`, each model fit can take quite some time (especially as the number of latent variables increases). Fitting all of the models serially can take days, and I've found it much more efficient to instead fit multiple models simultaneously, each in its own Matlab instance. The ability to do this of course depends on how beefy your CPU is, but with 4 or 6 cores you can easily fit 4 or 5 models simultaneously. Note that this requires using the `screen` command in Linux; I'm not sure if there is an equivalent in windows.

To check if `screen` is installed on Linux/Mac, type 
```
$ screen --version
```
into the command line. If it is not, then download using

```
$ sudo apt install screen
```
Next, you'll have to put a `startup.m` script into your Matlab home directory. This script will be called each time Matlab is started, and we can use this to point Matlab to the necessary directories programmatically. There is an example script `utils/startup.m`; move this into your Matlab home directory as `/home/user/Documents/MATLAB/startup.m` and change the paths as necessary.

Now you can use the function `scripts-gam/run_srlvms.sh`. This script will loop through multiple datasets and models. For each dataset/model, the script will launch an instance of Matlab in a detached `screen` session, call `startup.m` to find the GAM toolbox and the analysis scripts, then fit the model and exit when finished. The variable `max_screens` defines how many models will be fit in parallel. Once a model is finished fitting another will be launched until all models have been fit. An easy way to see which screens are currently on is to use the `screen -ls` command. To launch the script from the project home directory, run
```
$ bash scripts-gam/run_srlvms.sh
```

## Step 5: Fit tuning curves

The GAM models that we'll fit next use a stimulus model. We'll fit the stimulus models first, which can be used to initialize the GAMs, or, alternately, can be used as the fixed stimulus response that is not learned along with the parameters associated with the latent variables. The procedure is the same as fitting the (S)RLVMs, but using the `scripts-stim-models/fitStimModels.m` function. Analogously, a bash script `scripts-stim-models/run_stimulus.sh` is provided to speed up fitting using screens:

```
$ bash scripts-stim-models/run_stimulus.sh
```

## Step 6: Fit Additive/Multiplicative/Affine models

Next we'll fit models that have previously been introduced in the literature. The relevant high-level functions are `scripts-gam/scriptFitPreviousModels.m` and `scripts-gam/run_previous_models.sh`:

```
$ bash scripts-gam/run_previous_models.sh
```

With an Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz (6 double-threaded cores) the run time for this script was ~2 hours using 5 screens.

## Step 7: Fit (extended) GAM models

Next we'll fit the GAM models (e.g. Fig. 5B in the paper). The relevant high-level functions are `scripts-gam/scriptFitGAMs.m` and `scripts-gam/run_gams.sh`:

```
$ bash scripts-gam/run_gams.sh
```

Note that these models will take a significant amount of time to fit to all 6 experimental sessions; with an Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz (6 double-threaded cores) the fit time for all combinations of 0-4 additive and 0-4 multiplicative latent variables (with 5-fold cross-validation) was ~16 hours using 5 screens.

## Step 8: Plotting

Functions for creating the various panels in the paper figures are provided in the `plotting` directory; please see the README in that directory for more detailed information.
