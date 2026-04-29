function[] = noisyPseudoDA(targetName, priorName, attrition, loc, latBounds, skillYears, anomalyYears)
% Does the assimilations for the noisy pseudo-proxies

% NTREND metadata
ntrend = gridfile('ntrend.grid');
ntrend = ntrend.metadata;

% Load the prior
ens = ensemble(sprintf('%s-global.ens', priorName));
ensMeta = ens.metadata;
M = ens.load;

% Load the noisy proxies
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
D = proxies.Ynoisy;
regression = load(sprintf('%s-pseudo-psms.mat', targetName));
R = regression.noisy.R;

% Get the attrition tag
attName = 'noAttrition';
if attrition
    attName = 'attrition';
end

% Get the proxy estimates
estimates = load(sprintf('estimates-%s_target-%s_prior.mat', targetName, priorName));
Ye = estimates.Ye_noisy;

% Get latitude weights for time series
targetWeights = tsWeights(targetName, latBounds);
priorWeights = tsWeights([priorName,'-global'], latBounds);

% Get the target spatial reconstruction. Limit to skill years. 
target = ensemble(sprintf('%s.ens', targetName));
T = target.load;
use = ismember(year(target.metadata.variable('T','time')), skillYears);
T = T(:,use);

% Take the anomaly
anom = ismember(skillYears, anomalyYears);
T = T - mean(T(:,anom), 2);

% Calculate time series and regrid
Tts = sum(T .* targetWeights, 1) ./ sum(targetWeights);
Tts = Tts - mean(Tts(anom));
[T, Tmeta] = target.metadata.regrid(T, 'T', ["lat", "lon"]);

% Get localization weights
[wloc, yloc] = dash.localizationWeights('gc2d', ensMeta.latlon, ntrend.coord, loc);

% Preallocate time series skill metrics
nNoise = size(D,3);
ts = struct('rho', NaN(nNoise,1), 'rmse', NaN(nNoise,1), 'ratio', NaN(nNoise,1), 'bias', NaN(nNoise,1));

% Get the pseudo-proxies for each assimilation. Optionally apply attrtion
nNoise = size(D,3);
f = waitbar(0, '0%');
for n = 1:nNoise
    Dn = D(:,:,n);
    if attrition
        Dn = attrite(Dn, proxies.years);
    end

    % Build the kalman filter
    kf = kalmanFilter;
    kf = kf.prior(M);
    kf = kf.observations(Dn, R(:,:,n));
    kf = kf.estimates(Ye(:,:,n));
    kf = kf.returnVariance(false);
    kf = kf.localize(wloc, yloc);

    % Run the assimilation. Limit to skill years
    out = kf.run;
    A = out.Amean;
    use = ismember(proxies.years, skillYears);
    A = A(:,use);
    
    % Get spatial anomalies
    anom = ismember(skillYears, anomalyYears);
    A = A - mean(A(:,anom),2);
    
    % Get time series. Take time series anomalies
    Ats = sum(A .* priorWeights, 1) ./ sum(priorWeights);
    Ats = Ats - mean(Ats(anom));

    % Calculate time series skill metrics
    ts.rho(n) = pointCorr(Tts, Ats, 'dim', 2);
    ts.rmse(n) = pointRMSE(Tts, Ats, 'dim', 2);
    ts.ratio(n) = pointStdRatio(Tts, Ats, 'dim', 2);
    ts.bias(n) = pointMeanBias(Tts, Ats, 'dim', 2);

    % Regrid the spatial fields and match to a common resolution
    [A, Ameta] = ens.metadata.regrid(A, 'T', ["lat", "lon"]);
    [T, A, Tmeta] = matchGrids(T, Tmeta, A, Ameta);

    % Preallocate spatial skill metrics
    if n==1
        siz = [size(T,1), size(T,2), nNoise];
        rho = NaN(siz);
        rmse = NaN(siz);
        ratio = NaN(siz);
        bias = NaN(siz);
    end
    
    % Redo spatial anomalies for the regridded spatial products
    A = A - mean(A(:,:,anom), 3);
    T = T - mean(T(:,:,anom), 3);

    % Calculate spatial skill metrics
    rho(:,:,n) = pointCorr(T, A, 'dim', 3);
    rmse(:,:,n) = pointRMSE(T, A, 'dim', 3);
    ratio(:,:,n) = pointStdRatio(T, A, 'dim', 3);
    bias(:,:,n) = pointMeanBias(T, A, 'dim', 3);
    waitbar(n/nNoise, f, sprintf('%.f%%', 100*n/nNoise));
end
delete(f);

% Collect spatial metrics
spatial = struct('rho', rho, 'rmse', rmse, 'ratio', ratio, 'bias', bias, 'meta', Tmeta);

% Save
saveName = sprintf('%s_target-%s_prior-noisy-%s-skill.mat', targetName, priorName, attName);
save(saveName, 'spatial', 'ts', 'skillYears');

end