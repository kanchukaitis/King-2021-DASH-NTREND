function[] = collectTimeSeries(targetName, priorName, loc, latBounds, anomalyYears)

% Load the target and get the time series weights
target = ensemble(sprintf('%s-global.ens', targetName));
T = target.load;
weights = tsWeights([targetName,'-global'], latBounds);

% Load the PPR reconstruction, apply RE screening
ppr = load(sprintf('%s.noisy_attrition.mat',targetName));
P = ppr.gridded.t;
P(ppr.gridded.re<=0) = NaN;

% Use NaN for any grid that is NaN in 1000
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
years = proxies.years;
y1000 = years==1000;
nanval = isnan(P(y1000,:,:));
nanval = repmat(nanval, [size(P,1), 1, 1]);
P(nanval) = NaN;

% Regrid longitudes. Shape to state vector
nLon = size(P, 3);
half = nLon/2;
P = P(:, :, [half+1:nLon, 1:half]);
P = permute(P, [3 2 1]);
siz = size(P);
P = reshape(P, [siz(1)*siz(2), siz(3)]);

% Use DA to reconstruct one noisy time series
ens = ensemble(sprintf('%s.ens', priorName));
ensMeta = ens.metadata;
M = ens.load;
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
D = proxies.Ynoisy(:,:,1);
regression = load(sprintf('%s-pseudo-psms.mat', targetName));
R = regression.noisy.R(:,:,1);
estimates = load(sprintf('estimates-%s_target-%s_prior.mat', targetName, priorName));
Ye = estimates.Ye_noisy(:,:,1);
ntrend = gridfile('ntrend.grid');

kf = kalmanFilter;
kf = kf.prior(M);
kf = kf.observations(D, R);
kf = kf.estimates(Ye);
kf = kf.returnVariance(false);
[wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.metadata.coord, loc);
kf = kf.localize(wloc, yloc);
out = kf.run;

% Take anomalies
anom = ismember(proxies.years, anomalyYears);
P = P - nanmean(P(:,anom),2);
T = T - mean(T(:,anom),2);
out.Amean = out.Amean - mean(out.Amean(:,anom),2);


% Get the time series
ts = struct;
ts.target.ts = sum(T .* weights, 1) ./ sum(weights);

weights = repmat(weights, [1 size(P,2)]);
weights(isnan(P)) = NaN;
ts.ppr.ts = nansum(P .* weights, 1) ./ nansum(weights);

weights = tsWeights(priorName, latBounds);
ts.da.ts = sum(out.Amean .* weights, 1) ./ sum(weights);

% Take the anomalies and get running standard deviation
name = ["target","da","ppr"];
nRun = 31;
for n = 1:3
    current = ts.(name(n)).ts;
    ts.(name(n)).ts = current - mean(current(anom));
    ts.(name(n)).std = movstd(ts.(name(n)).ts, nRun, 'Endpoints', 'fill');
end

% Save
saveName = sprintf('time-series-%s_target.mat', targetName);
years = proxies.years;
save(saveName, 'ts', 'years');

end