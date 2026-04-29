function[] = pprSkill(targetName, noiseType, attritionType, latBounds, skillYears, anomalyYears)

% Load the PPR reconstruction, apply RE screening
ppr = load(sprintf('%s.%s_%s.mat',targetName, noiseType, attritionType));
A = ppr.gridded.t;
% A(ppr.gridded.re<=0) = NaN;

% % % Use NaN for any grid that is NaN in 1000
proxies = load(sprintf('%s-pseudoproxies.mat',targetName));
years = proxies.years;
% % y1000 = years==1000;
% % nanval = isnan(A(y1000,:,:));
% % nanval = repmat(nanval, [size(A,1), 1, 1]);
% % A(nanval) = NaN;

% Regrid longitudes. Shape to state vector
nLon = size(A, 3);
half = nLon/2;
A = A(:, :, [half+1:nLon, 1:half]);
A = permute(A, [3 2 1]);
siz = size(A);
A = reshape(A, [siz(1)*siz(2), siz(3)]);

% Load the target
target = ensemble(sprintf('%s-global.ens', targetName));
T = target.load;

% Limit to skill metric years
use = ismember(years, skillYears);
T = T(:,use);
A = A(:,use);

% Take the spatial anomalies
anom = ismember(skillYears, anomalyYears);
T = T - mean(T(:,anom),2);
A = A - nanmean(A(:,anom),2);

% Get the time series
weights = tsWeights(strcat(targetName, '-global'), latBounds);
Ats = nansum(A .* weights, 1) ./ nansum(weights);
Tts = sum(T .* weights, 1) ./ sum(weights);

% Time series anomalies 
Ats = Ats - nanmean(Ats(anom));
Tts = Tts - mean(Tts(anom));

% Match spatial grids
[A, meta] = target.metadata.regrid(A, 'T', ["lat", "lon"]);
T = target.metadata.regrid(T, 'T', ["lat", "lon"]);

% Redo anomalies for the regridded spatial products
A = A - nanmean(A(:,:,anom), 3);
T = T - mean(T(:,:,anom), 3);

% Calculate spatial skill metrics
rho = pointCorr(T, A, 'dim', 3, 'nanflag', 'omitnan');
rmse = pointRMSE(T, A, 'dim', 3, 'meanArgs', {'omitnan'});
ratio = pointStdRatio(T, A, 'dim', 3, 'stdArgs', {'omitnan'});
bias = pointMeanBias(T, A, 'dim', 3, 'meanArgs', {'omitnan'});
spatial = struct('rho', rho, 'rmse', rmse, 'ratio', ratio, 'bias', bias, 'meta', meta);

% Calculate time series skill metrics
rho = pointCorr(Tts, Ats, 'dim', 2, 'nanflag', 'omitnan');
rmse = pointRMSE(Tts, Ats, 'dim', 2, 'meanArgs', {'omitnan'});
ratio = pointStdRatio(Tts, Ats, 'dim', 2, 'stdArgs', {'omitnan'});
bias = pointMeanBias(Tts, Ats, 'dim', 2, 'meanArgs', {'omitnan'});
ts = struct('rho', rho, 'rmse', rmse, 'ratio', ratio, 'bias', bias);

% Save
if strcmp(attritionType, 'full')
    attritionType = 'noAttrition';
end
saveName = sprintf('ppr-%s_target-%s-%s-skill.mat', targetName, noiseType, attritionType);
save(saveName, 'spatial', 'ts', 'skillYears', 'latBounds');

end