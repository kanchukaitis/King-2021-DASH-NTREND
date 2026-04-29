function[] = pseudoLocalization(targetName, priorName, locs, calibrationYears, latBounds)
%% Selects a localization radius for the pseudo-proxy experiments

% NTREND metadata
ntrend = gridfile('ntrend.grid');
ntrend = ntrend.metadata;

% Load the prior
ens = ensemble(sprintf('%s.ens', priorName));
ensMeta = ens.metadata;
M = ens.load;

% Load the noisy proxies
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
D = proxies.Ynoisy;

% Get the observation uncertainty
regression = load(sprintf('%s-pseudo-psms.mat', targetName));
R = regression.noisy.R;

% Get the proxy estimates
estimates = load(sprintf('estimates-%s_target-%s_prior.mat', targetName, priorName));
Ye = estimates.Ye_noisy;

% Only assimilate the calibration period
calib = ismember( proxies.years, calibrationYears );
D = D(:,calib,:);

% Get latitude weights for spatial mean
weights = tsWeights(priorName, latBounds);

% Preallocate the time series
nTime = numel(calibrationYears);
nLoc = numel(locs);
ts = NaN(nTime, nLoc);

% Initialize the Kalman filter
kf = kalmanFilter;
kf = kf.prior(M);
kf = kf.observations(D(:,:,1), R(:,:,1));
kf = kf.estimates(Ye(:,:,1));
kf = kf.returnVariance(false);

% Run each assimilation with the requested localization
tic
for k = 1:nLoc
    [wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.coord, locs(k));
    kf = kf.localize(wloc, yloc);
    out = kf.run;
    
    % Extract the extratropical spatial mean
    ts(:,k) = sum(out.Amean .* weights, 1) ./ sum(weights);
end
toc

% Save the time series
saveName = sprintf('pseudoLocTS-%s_target-%s_prior.mat', targetName, priorName);
save(saveName, 'ts', 'calibrationYears', 'locs', 'latBounds');

end