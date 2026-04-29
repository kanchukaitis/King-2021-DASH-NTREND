function[] = volcanicEnsemble(volcYears, nAnomaly)

% Load the reconstruction
recon = load('ensemble-reconstruction.mat');

% Get each volcanic event, preceding 5 years, and following year
[~, loadTime] = ismember(volcYears(:)', recon.years);
adjust = (-nAnomaly:1)';
loadTime = loadTime + adjust;
loadTime = loadTime(:);

% Load the data
volc = recon.T(:,:,loadTime);
meta = recon.Tmeta;

% Separate volcanic events
siz = size(volc);
nYears = nAnomaly+2;
nVolc = numel(volcYears);
volc = reshape(volc, [siz(1), siz(2), nYears, nVolc]);

% Get the anomaly
anomaly = volc(:,:,1:nAnomaly,:);
anomaly = mean(anomaly, 3);
volc = volc(:,:,nAnomaly+(1:2),:);
volc = volc - anomaly;

% Take the composite mean
volc = nanmean(volc, 4);

% Save
saveName = 'volcanic-composite-ensemble.mat';
save(saveName, 'volc', 'volcYears', 'nAnomaly', 'meta');

end