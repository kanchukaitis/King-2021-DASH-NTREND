function[] = perfectPseudoDA(targetName, priorName, attrition, loc, latBounds, skillYears, anomalyYears)
% Does the assimilations for the perfect pseudo-proxies

% NTREND metadata
ntrend = gridfile('ntrend.grid');
ntrend = ntrend.metadata;

% Load the prior
ens = ensemble(sprintf('%s-global.ens', priorName));
ensMeta = ens.metadata;
M = ens.load;

% Load the perfect proxies
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
D = proxies.Yperfect;

regression = load(sprintf('%s-pseudo-psms.mat', targetName));
R = regression.perfect.R;

% Optionally apply attrition
attName = 'noAttrition';
if attrition
    attName = 'attrition';
    D = attrite(D, proxies.years);
end

% Get the proxy estimates
estimates = load(sprintf('estimates-%s_target-%s_prior.mat', targetName, priorName));
Ye = estimates.Ye_perfect;

% Get latitude weights for time series
targetWeights = tsWeights(targetName, latBounds);
priorWeights = tsWeights(strcat(priorName, '-global'), latBounds);

% Get localization weights
[wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.coord, loc);

% Create the Kalman filter
kf = kalmanFilter;
kf = kf.prior(M);
kf = kf.observations(D, R);
kf = kf.estimates(Ye);
kf = kf.returnVariance(false);
kf = kf.localize(wloc, yloc);

% Run the assimilation. Also get the target spatial reconstruction
out = kf.run;
A = out.Amean;
target = ensemble(sprintf('%s.ens', targetName));
T = target.load;

% Limit to the years of the skill metric
use = ismember(proxies.years, skillYears);
A = A(:,use);
use = ismember(year(target.metadata.variable('T','time')), skillYears);
T = T(:,use);

% Take the anomaly
anom = ismember(skillYears, anomalyYears);
A = A - mean(A(:,anom), 2);
T = T - mean(T(:,anom), 2);

% Get the time series
Ats = sum(A .* priorWeights, 1) ./ sum(priorWeights);
Tts = sum(T .* targetWeights, 1) ./ sum(targetWeights);

% Take the time-series anomaly
anom = ismember(skillYears, anomalyYears);
Ats = Ats - mean(Ats(anom));
Tts = Tts - mean(Tts(anom));

% Calculate time series skill metrics
rho = pointCorr(Tts, Ats, 'dim', 2);
rmse = pointRMSE(Tts, Ats, 'dim', 2);
ratio = pointStdRatio(Tts, Ats, 'dim', 2);
bias = pointMeanBias(Tts, Ats, 'dim', 2);
ts = struct('rho', rho, 'rmse', rmse, 'ratio', ratio, 'bias', bias);

% Regrid the spatial fields and match to a common resolution
[T, Tmeta] = target.metadata.regrid(T, 'T', ["lat", "lon"]);
[A, Ameta] = ens.metadata.regrid(A, 'T', ["lat", "lon"]);
[T, A, meta] = matchGrids(T, Tmeta, A, Ameta);

% Redo anomalies for the spatial regrids
A = A - mean(A(:,:,anom),3);
T = T - mean(T(:,:,anom),3);

% Calculate spatial skill metrics
rho = pointCorr(T, A, 'dim', 3);
rmse = pointRMSE(T, A, 'dim', 3);
ratio = pointStdRatio(T, A, 'dim', 3);
bias = pointMeanBias(T, A, 'dim', 3);
spatial = struct('rho', rho, 'rmse', rmse, 'ratio', ratio, 'bias', bias, 'meta', meta);

% Save
saveName = sprintf('%s_target-%s_prior-perfect-%s-skill.mat', targetName, priorName, attName);
save(saveName, 'spatial', 'ts', 'skillYears');

end
