function[] = locCalibration(priorName, anomalyYears)

% Load the localization tests
out = load(sprintf('locTS-%s_prior.mat', priorName));

% Load the calibration target in the calibration years
cru = ensemble('cru.ens');
T = cru.load;

years = year(cru.metadata.variable('T', 'time'));
use = ismember(years, out.calibrationYears);
T = T(:,use);

% Take the spatial anomaly
anom = ismember(out.calibrationYears, anomalyYears);
T = T - mean(T(:,anom),2);

% Get the target time series
weights = tsWeights('cru', out.latBounds);
weights = repmat(weights, [1 size(T,2)]);
weights(isnan(T)) = NaN;
ts = nansum(T.*weights, 1) ./ nansum(weights, 1);

% Take the time series anomaly
ts = ts - mean(ts(anom));

% Preallocate the best radius for each calibration interval
nInterval = numel(out.calibrationYears);
bestLoc = NaN(nInterval, 1);

% Iterate through each calibration/validation interval
nCalib = ceil(nInterval/2);
for k = 1:nInterval
    calib = mod(k:k+nCalib-1, nInterval);
    calib(calib==0) = nInterval;

    % Get sigma ratios
    targetStd = std(ts(calib));
    reconStd = std(out.ts(calib,:), [], 1);
    ratios = reconStd / targetStd;
    
    % Find the radius closest to 1
    dist = abs(ratios-1);
    closest = min(dist);
    best = find(dist==closest, 1);
    bestLoc(k) = out.locs(best);
end

% Save the skill metrics and best radii
saveName = sprintf('locRadius-%s_prior.mat', priorName);
calibrationYears = out.calibrationYears;
save(saveName, 'bestLoc', 'calibrationYears');

end