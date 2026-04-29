function[] = pseudoLocSkill(targetName, priorName)

% Load the target ensemble and pseudo-localization output
target = ensemble(sprintf('%s.ens', targetName));
T = target.load;
out = load(sprintf('locRadius-%s_target-%s_prior.mat', targetName, priorName));

% Get the target time series
weights = tsWeights(targetName, out.latBounds);
ts = sum(T .* weights, 1) ./ sum(weights);

% Restrict to the calibration interval
years = year(target.metadata.variable('T', 'time'));
calib = ismember(years, out.calibrationYears);
ts = ts(calib)';

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
saveName = sprintf('pseudoLocSkill-%s_target-%s_prior.mat', targetName, priorName);
calibrationYears = out.calibrationYears;
save(saveName, 'bestLoc', 'calibrationYears');

end