function[] = timeSeriesValidation(priorName, validationYears, anomalyYears)

% Load the reconstruction and limit time series to the validation interval
recon = load(sprintf('%s-reconstruction.mat', priorName));
valid = ismember(recon.years, validationYears);
recon.ts = recon.ts(valid)';

% Load the Berkeley Earth target and reconstruction
be = ensemble('be.ens');
T = be.load;

% Get the BE extratropical time series
weights = tsWeights('be', recon.latBounds);
weights = repmat(weights, [1 size(T,2)]);
weights(isnan(T)) = NaN;
ts = nansum(T.*weights, 1) ./ nansum(weights, 1);

% Restrict to the validation interval
years = year(be.metadata.variable('T', 'time'));
valid = ismember(years,  validationYears);
ts = ts(valid)';

% Take anomalies
anom = ismember(validationYears, anomalyYears);
ts = ts - mean(ts(anom));
recon.ts = recon.ts - mean(recon.ts(anom));

% Preallocate skill metrics
nInterval = numel(validationYears);
rho = NaN(nInterval, 1);
rmse = NaN(nInterval, 1);
ratio = NaN(nInterval, 1);
bias = NaN(nInterval, 1);

% Iterate through each validation interval
nValid = ceil(nInterval/2);
for k = 1:nInterval
    valid = mod(k:k+nValid-1, nInterval);
    valid(valid==0) = nInterval;

    B = ts(valid);
    R = recon.ts(valid);
    
    % Calculate skill metrics
    rho(k) = pointCorr(B, R, 'dim', 1);
    rmse(k) = pointRMSE(B, R, 'dim', 1);
    ratio(k) = pointStdRatio(B, R, 'dim', 1);
    bias(k) = pointMeanBias(B, R, 'dim', 1);
end

% Save
saveName = sprintf('%s-time-series-skill.mat', priorName);
save(saveName, 'rho', 'rmse', 'ratio', 'bias', 'validationYears');

end