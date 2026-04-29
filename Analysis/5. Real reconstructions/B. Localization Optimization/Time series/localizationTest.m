function[] = localizationTest(priorName, locs, calibrationYears, latBounds, anomalyYears)

% Load the prior
ens = ensemble(sprintf('%s.ens', priorName));
ensMeta = ens.metadata;
M = ens.load;

% Load the proxies and uncertainty
ntrend = gridfile('ntrend.grid');
D = ntrend.load;
ntrend = ntrend.metadata;

regression = load('ntrend-regression.mat');
R = regression.R;

% Proxy estimates
Ye = load(sprintf('%s-ntrend-estimates.mat', priorName));
Ye = Ye.Ye;

% Remove any ensemble members with NaN
delete = ens.hasnan | any(isnan(Ye),1);
M(:,delete) = [];
Ye(:,delete) = [];

% Only assimilate the calibration period
calib = ismember( ntrend.time, calibrationYears );
D = D(:,calib);

% Get latitude weights for spatial mean
weights = tsWeights(priorName, latBounds);

% Preallocate the time series
nTime = numel(calibrationYears);
nLoc = numel(locs);
ts = NaN(nTime, nLoc);

% Initialize the Kalman filter
kf = kalmanFilter;
kf = kf.prior(M);
kf = kf.observations(D, R);
kf = kf.estimates(Ye);
kf = kf.returnVariance(false);

% Run each assimilation with the requested localization
tic
for k = 1:nLoc
    k
    [wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.coord, locs(k));
    kf = kf.localize(wloc, yloc);
    out = kf.run;
    
    % Get the spatial anomaly
    A = out.Amean;
    anom = ismember(calibrationYears, anomalyYears);
    A = A - mean(A(:,anom),2);
    
    % Extract the extratropical spatial mean and take the time series
    % anomaly
    ts(:,k) = sum(A .* weights, 1) ./ sum(weights);
    ts(:,k) = ts(:,k) - mean(ts(anom,k));
end
toc

% Save the time series
saveName = sprintf('locTS-%s_prior.mat', priorName);
save(saveName, 'ts', 'calibrationYears', 'locs', 'latBounds');

end