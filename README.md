[![DOI:10.5281/zenodo.3989941](https://zenodo.org/badge/DOI/10.5281/zenodo.3989941.svg)](https://zenodo.org/record/3989941)

[![Uses Matlab 2020b](https://img.shields.io/badge/Uses-Matlab_2020b-green)](https://www.mathworks.com/downloads/web_downloads/download_release?release=R2020b)
[![License: Create Commons Attribution 4.0 International](https://img.shields.io/badge/License-CC--BY_4.0-red)](https://creativecommons.org/licenses/by/4.0/legalcode)
[![License: Create Commons Attribution 4.0 International](https://licensebuttons.net/l/by/4.0/88x31.png)](https://creativecommons.org/licenses/by/4.0/legalcode)


# Contents
This repository includes the data, code, and reconstructions used to produce the figures in the paper:

[![DOI:10.1175/JCLI-D-20-0661.1](https://img.shields.io/badge/DOI-10.1175/JCLI--D--20--0661.1-0273b3)](https://doi.org/10.1175/JCLI-D-20-0661.1)

King, J. M., Anchukaitis, K. J., Tierney, J. E., Hakim, G. J., Emile-Geay, J., Zhu, F., & Wilson, R. (2021). **A data assimilation approach to last millennium temperature field reconstruction using a limited high-sensitivity proxy network.** *Journal of Climate*, 1-64.

The repository contains 4 zip files:

Zip File | Description
-------- | -----------
Input Datasets | The NTREND chronologies, climate model output, instrumental reanalysis data, and temperature reconstructions used in the paper.
Analysis | The Matlab code used to produce the analysis, as well as saved results.
Figures | The code used to produce the figures in the paper, as well as saved versions of the figures.
Final reconstructions | The DA reconstructions exported to NetCDF files.

### Input Datasets

This file contains the raw input datasets used to produce this paper. Raw output for each climate model is located in the model's subdirectory in the "Climate Model Output" folder. The NTREND chronologies are located in the "NTREND" folder, and the instrumental reanalyses used for skill validation (CRU TS 4.01 and Berkeley Earth) are in the "Instrumental Reanalyses". Finally, the external temperature climate field reconstructions (CFRs) are located in the "Temperature CFRs" folder.

### Analysis

This folder contains the source code and saved results from the analysis. Major steps of the analysis are organized into ordered subfolders for convenience. The function "mainAnalysis.m" includes all the parameters used in the experiment, and demonstrates how to call the functions used to produce the results. Saved results are stored as .mat files in their respective subdirectories.

The data assimilation routines in this analysis are implemented using a prototype of [DASH v4.0.0](https://github.com/JonKing93/DASH), a Matlab package for paleoclimate data assimilation. This prototype is included in the "DASH-4.0.0-alpha-4.0.0" folder. Additional functions used by many of the analysis scripts are located in the "utility functions" folder.

### Figures

This folder holds the scripts used to produce the figures in the paper, as well as saved versions of the figures. The function "makeFigures.m" demonstrates how to call the functions used to generate the various figures, and the source code for each of the figures is stored in the "Figure Scripts" folder. The "plotting utilities" includes Matlab functions used to generate multiple figures. Finally, the "Saved Figures" folder holds the raw figures used in the paper, saved in a .eps format.

**Important**: The scripts that generate the figures require saved results that are stored in the "Analysis" zip folder. You will need to add the contents of the "Analysis" folder to your Matlab path if you want to re-generate the figures.

### Final Reconstructions

This folder holds the DA reconstructions, exported to a NetCDF format. It includes the reconstruction for each model prior, as well as the multi-model ensemble mean reconstruction. The reconstructions for the model priors include:
1. Spatial surface temperature anomalies,
2. Time series of mean extratropical temperature anomalies, and
3. Uncertainties as determined using the variance of the posterior.

The ensemble mean reconstruction includes:
1. The multi-model mean of the spatial and time series reconstructions,
2. Variance across the multi-model ensemble, and
3. The mean of the posterior variances for the 10 single-model reconstructions.


# Software Requirements

This analysis was conducted using Matlab 2020b. More specifically, using version 9.9.0.1495850 (2020b) Update 1.

The "Analysis" and "Figures" zip files should contain all additional packages required to run the analysis and generate the figures.

In order to re-run the analysis:
1. Download and extract the "Analysis" and "Figures" zip files
2. Add both folders, and all subfolders, to the Matlab active path
3. See mainAnalysis.m for examples of how to run the analysis scripts
4. See makeFigures.m for a demonstration of how to generate the figures.
