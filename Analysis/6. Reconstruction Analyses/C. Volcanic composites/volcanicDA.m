function[] = volcanicDA(name, volcYears, nAnomaly)

% Load the spatial reconstruction and get the ensemble metadata
recon = load(sprintf('%s-reconstruction.mat', name));
ens = ensemble(sprintf('%s.ens', name));
ensMeta = ens.metadata;

% Get each volcanic event, preceding 5 years, and following year
[~, loadTime] = ismember(volcYears(:)', recon.years);
adjust = (-nAnomaly:1)';
loadTime = loadTime + adjust;
loadTime = loadTime(:);

% Load the data.
[volc, meta] = ensMeta.regrid(recon.out.Amean(:,loadTime), 'T', ["lat", "lon"]);

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
saveName = sprintf('volcanic-composite-%s.mat', name);
save(saveName, 'volc', 'volcYears', 'nAnomaly', 'meta');

end