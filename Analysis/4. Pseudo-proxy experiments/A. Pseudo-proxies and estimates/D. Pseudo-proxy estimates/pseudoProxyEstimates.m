function[] = pseudoProxyEstimates(targetName, priorName, anomalyYears)
%% Generates pseudo-proxy estimates for a target model and prior

% Load the prior and target at ntrend, as well as the psms
target = load(sprintf('%s-at-ntrend.mat', targetName));
prior = load(sprintf('%s-at-ntrend.mat', priorName));
psm = load(sprintf('%s-pseudo-psms.mat', targetName));

% Get the target mean in the anomaly years
anom = ismember(target.years, anomalyYears);
targetMean = mean(target.T(:,anom), 2);

% Bias correct the prior to match the target mean in the anomaly years
anom = ismember(prior.years, anomalyYears);
priorMean = mean(prior.T(:,anom), 2);
prior.T = prior.T - priorMean + targetMean;

% Get the estimates
Ye_perfect = psm.perfect.intercept + psm.perfect.slope .* prior.T;
Ye_noisy = psm.noisy.intercept + psm.noisy.slope .* prior.T;

% Save
saveName = sprintf('estimates-%s_target-%s_prior.mat', targetName, priorName);
save(saveName, 'Ye_perfect', 'Ye_noisy');

end