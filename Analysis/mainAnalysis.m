%% Analysis parameters

% General parameters
testLocs = [250:250:50000, Inf];    % The localization radii to test in the optimization
calibrationTarget = 'cru';          % The data product to use for PSM calibration
calibrationYears = 1901:1988;       % The years to use for PSM calibration
latBounds = [30 90];                % The latitude bounds to use for spatial means
anomalyYears = 1951:1980;           % The anomaly period to use for the reconstructions

% Pseudo-proxy parameters
pseudoModels = ["cesm", "mpi"];     % The models used for pseudo-proxy experiments
nNoise = 101;                       % The number of noise realizations to use for noisy proxies
pseudoSkillYears = 850:1988;        % The years over which to compute skill for the pseudo-proxies

% Real reconstruction parameters
models = ...                        % The model priors to assimilate
    ["bcc","ccsm4","cesm","csiro","hadcm3","fgoals","ipsl","miroc","mpi","mri"];
validationYears = 1901:1988;        % The years to use for skill validation

% Reconstruction analyses
cfrs = ...                          % The exernal CFRs to examine
    ["ntrend","neukomda","lmr21","zhu","guillet"];
mcaYears = 950:1250;                % Medieval Climate Anomaly years
liaYears = 1450:1850;               % Little Ice Age years
volcanicAnomaly = 5;                % The number of preceding years to use for calculating volcanic anomalies
minVolcEvents = 6;                  % The minimum number of volcanic events required for a grid cell to be used in the volcanic composites
volcanicYears = ...                 % The volcanic years to use for superposed epoch analysis (SEA)
    [916 1108 1171 1191 1230 1258 1276 1286 1345 1453 1458 1595, 1601 1641 1695 1809 1815 1832 1836 1884];


%% Organize input data sets

% Climate models
buildBCCtas;
buildCCSM4tas;
buildCESMtas;
buildCSIROtas;
buildFGOALStas;
buildHadCM3tas;
buildIPSLtas;
buildMIROCtas;
buildMPItas;
buildMRItas;

% Instrumental reanalyses
buildBerkeleyGrid;
buildCRUGrid;

% NTREND
buildNTRENDGrid;

% Temperature CFRs
buildAnchukaitisGrid;
buildGuilletGrid;
buildNeukomGrid;
buildLMR21Grid;
buildZhuGrid;


%% Regress NTREND against CRU

% Get seasonal mean temperatures at the NTREND sites for CRU
siteTemperatures('cru');

% Do the regression, save the coefficients
regress_NTREND_CRU;


%% Build priors

% Build global priors/targets for the pseudo-proxy assimilations
for p = 1:numel(pseudoModels)
    buildGlobalPrior( pseudoModels(p) );
end

% Build extratropical priors for the real assimilations / pseudo-proxy
% localization optimization
for m = 1:numel(models)
    buildPrior( models(m) );
end

% Build extratropical targets using the instrumental reanalyses
for t = 1:numel(renalyses)
    buildPrior( reanalyses(t) );
end

%% Pseudo-proxy experiments

% For each target model, get the seasonal mean temperatures, generate
% pseudo-proxies, and get regression coefficients for pseudo-proxy PSMs
for t = 1:numel(pseudoModels)
    siteTemperatures(pseudoModels(t));
    pseudoProxies(pseudoModels(t), nNoise);
    pseudoProxyRegression(pseudoModels(t));
    
    % Use the pseudo-PSMs to generate pseudo-proxy estimates
    for p = 1:numel(pseudoModels)
        pseudoProxyEstimates(pseudoModels(t), pseudoModels(p), anomalyYears);
    end
end
    
% Assimilate each target-prior pair of models
biasedPrior = fliplr(pseudoModels);
for t = 1:numel(pseudoModels)
    target = pseudoModels(t);
    for p = 1:numel(pseudoModels)
        prior = pseudoModels(p);
        
        % Test the pseudo-proxy assimilations for different localization
        % radii. Calculate the skill of each radius and select the best radius
        pseudoLocalization(target, prior, testLocs, calibrationYears, latBounds);
        pseudoLocSkill(target, prior);
        loc = bestPseudoLoc(target, prior);
        
        % Assimilate the pseudo-proxy networks and alternate between
        % perfect/noisy proxies, and attrition/full networks
        attrition = [true false];
        attritionType = ["full", "attrition"];
        for a = 1:2
            perfectPseudoDA(target, prior, attrition(a), loc, latBounds, pseudoSkillYears, anomalyYears);
            noisyPseudoDA(target, prior, attrition(a), loc, latBounds, pseudoSkillYears, anomalyYears);
        end
    end
end


%% DA - PPR Comparison

% Do comparison for the biased-model, noisy-proxy, attrition pseudoproxies
target = pseudoModels;
prior = fliplr(pseudoModels);
for k = 1:numel(target)
    
    % Get the spatial skill of the PPR reconstructions
    pprSkill(target(k), "noisy", "attrition", latBounds, pseudoSkillYears, anomalyYears);
    
    % Collect the time series for both methods
    loc = bestPseudoLoc(target(k), prior(k));
    collectTimeSeries(target(k), prior(k), loc, latBounds, anomalyYears);
    
    % Compare skill scores
    compareMethods(target(k), prior(k));
end


%% Real reconstructions

% Get proxy estimates for each model
for m = 1:numel(models)
    siteTemperatures(models(m));
    estimateProxies(models(m));
end

% Get the optimal localization radius for each assimilation
for m = 1:numel(models)
    localizationTest(models(m), testLocs, calibrationYears, latBounds, anomalyYears);
    locCalibration(models(m), anomalyYears);
    loc = bestLoc(models(m));
    
    % Run each assimilation and also the proxy knockouts
    realAssimilation(models(m), loc, latBounds, anomalyYears);
    proxyKnockouts(models(m), loc);
    
    % Validate time series skill against Berkeley Earth
    timeSeriesValidation(models(m), validationYears, anomalyYears);
end

% Create the multi-model ensemble mean reconstruction and get its skill
ensembleReconstruction(models);
ensembleSpatialSkill(validationYears);
ensembleTimeSeriesSkill(validationYears);


%% Reconstruction analyses

% Compare the DA time series to Anchukaitis 2017 and Berkeley Earth
timeSeriesAnalysis;

% Epochal temperatures (MCA - LIA)
for m = 1:numel(models)
    epochalChangesDA(models(m), mcaYears, liaYears);
end
for c = 1:numel(cfrs)
    epochalChangesCFR(cfrs(c), mcaYears, liaYears);
end
epochalChangesEnsemble(mcaYears, liaYears);

% Volcanic composite maps
for m = 1:numel(models)
    volcanicDA(models(m), volcanicYears, volcanicAnomaly);
end
for c = 1:numel(cfrs)
    volcanicCFR(cfrs(c), volcanicYears, volcanicAnomaly, minVolcEvents);
end
volcanicEnsemble(volcanicYears, volcanicAnomaly);

% 1258 and 1601 events for the DA model ensemble mean reconstruction
volcanicEvent(1258);
volcanicEvent(1601);


%% Export reconstructions to NetCDF

% Individual reconstructions
for m = 1:numel(models)
    exportReconstruction(models(m));
end
exportEnsembleMean;