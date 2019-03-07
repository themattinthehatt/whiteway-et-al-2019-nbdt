## Characterizing the nonlinear structure of shared variability in cortical neuron populations using latent variable models

This repository contains code for replicating the analyses carried out by Whiteway et al. in the paper _Characterizing the nonlinear structure of shared variability in cortical neuron populations using latent variable models_, available [here](https://www.biorxiv.org/content/biorxiv/early/2018/09/04/407858.full.pdf). Instructions are located below.

## Step 1: Acquire data

We analyzed two publicly available datasets. 

**V1 dataset**. We analyzed electrophysiology data from the Kohn Lab, which has been made publicly available by CRCNS at http://dx.doi.org/10.6080/K0NC5Z4X. Spiking activity was recorded with a Utah array in primary visual cortex from three anesthetized macaques, in response to full-contrast drifting gratings with 12 equally-spaced directions, presented for 1280 ms (200 repeats). Full details can be found in the original paper [here](https://www.ncbi.nlm.nih.gov/pubmed/19036953). If you have not accessed data from CRCNS before you will have to first request access (as detailed [here](http://crcns.org/download)). Place the `pvc-11` directory containing the raw data anywhere in your directory; we'll specify the location later in a Matlab configuration file.

**PFC dataset**. We also analyzed electrophysiology data from the Kiani Lab, which has been made publicly available at http://www.cns.nyu.edu/kianilab/Datasets.html. Spiking activity was recorded with a Utah array in area 8Ar of the prearcuate gyrus from three macaques as they performed a direction discrimination task. On each trial the monkey was presented with a random dot motion stimulus for 800 ms, and after a variable-length delay period the monkey
reported the perceived direction of motion by saccading to a target in the corresponding direction. The coherence of the dots and their direction of motion varied randomly from trial to trial. As before, place the data directory anywhere in your directory.

## Step 2: Initialize project







