function[] = ensembleTimeSeriesSkill(skillYears)

% Load the reconstruction and limit time series to the skill period
recon = load('ensemble-reconstruction.mat');
Ats = recon.recon.ts.ts;
use = ismember(recon.years, skillYears);
Ats = Ats(use);

% Load the Berkeley earth target in the assessment interval
be = ensemble('be.ens');
T = be.load;
years = year(be.metadata.variable('T', 'time'));
use = ismember(years,  skillYears);
T = T(:,use);

% BE spatial anomaly
anom = ismember(skillYears, recon.anomalyYears);
T = T - mean(T(:,anom),2);

% Get the BE extratropical time series
weights = tsWeights('be', recon.recon.ts.latBounds);
weights = repmat(weights, [1 size(T,2)]);
weights(isnan(T)) = NaN;
ts = nansum(T.*weights, 1) ./ nansum(weights, 1);

% Time series anomaly
ts = ts - mean(ts(anom));
ts = ts';

% Calculate skill metrics
rho = pointCorr(ts, Ats);
rmse = pointRMSE(ts, Ats);
ratio = pointStdRatio(ts, Ats);
bias = pointMeanBias(ts, Ats);

% Save the metrics
anomalyYears = recon.anomalyYears;
save('ensemble-time-series-skill.mat', 'rho', 'rmse', 'ratio', 'bias', 'skillYears', 'anomalyYears');

end
