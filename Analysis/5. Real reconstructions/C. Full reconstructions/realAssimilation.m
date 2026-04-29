function[] = realAssimilation(priorName, loc, latBounds, anomalyYears)

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

% Build and run the kalman filter
kf = kalmanFilter;
kf = kf.prior(M);
kf = kf.observations(D, R);
kf = kf.estimates(Ye);
[wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.coord, loc);
kf = kf.localize(wloc, yloc);
weights = tsWeights(priorName, latBounds);
kf = kf.index('extra', weights);
out = kf.run;

% Take the spatial anomaly
anom = ismember(ntrend.time, anomalyYears);
out.Amean = out.Amean - mean(out.Amean(:,anom),2);

% Get the extratropical time series. Take the time series anomaly
weights = tsWeights(priorName, latBounds);
ts = sum(out.Amean .* weights, 1) ./ sum(weights);
ts = ts - mean(ts(anom));

% Run and save the output
saveName = sprintf('%s-reconstruction.mat', priorName);
years = ntrend.time;
save(saveName, 'out', 'years', 'ts', 'latBounds');

end
