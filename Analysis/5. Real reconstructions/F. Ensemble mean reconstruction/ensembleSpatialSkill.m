function[] = ensembleSpatialSkill(skillYears)

% Load the reconstruction and limit to the skill years
recon = load('ensemble-reconstruction.mat');
A = recon.recon.spatial.T;
Ameta = recon.recon.spatial.meta;
use = ismember(recon.years, skillYears);
A = A(:,:,use);

% Load the Berkeley earth target in the assessment interval
be = ensemble('be.ens');
T = be.load;
years = year(be.metadata.variable('T', 'time'));
use = ismember(years,  skillYears);
T = T(:,use);

% BE spatial anomaly
anom = ismember(skillYears, recon.anomalyYears);
T = T - mean(T(:,anom),2);

% Regrid BE
[T, Tmeta] = be.metadata.regrid(T, 'T', ["lat", "lon"]);
neg = Tmeta.lon<0;
T = cat(2, T(:,~neg,:), T(:,neg,:));
Tmeta.lon = cat(1, Tmeta.lon(~neg), 360+Tmeta.lon(neg));

% Match grids, redo spatial anomalies
T = matchGrids(T, Tmeta, A, Ameta);
T = T - mean(T(:,:,anom),3);

% Calculate skill metrics
rho = pointCorr(T, A, 'dim', 3, 'nanflag', 'omitnan');
rmse = pointRMSE(T, A, 'dim', 3, 'meanArgs', {'omitnan'});
ratio = pointStdRatio(T, A, 'dim', 3, 'stdArgs', {'omitnan'});
bias = pointMeanBias(T, A, 'dim', 3, 'meanArgs', {'omitnan'});

% Save the metrics
meta = Ameta;
anomalyYears = recon.anomalyYears;
save('ensemble-spatial-skill.mat', 'rho', 'rmse', 'ratio', 'bias', 'skillYears', 'anomalyYears', 'meta');

end