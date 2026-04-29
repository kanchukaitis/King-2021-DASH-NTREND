function[] = volcanicCFR(cfrName, volcYears, nAnomaly, nMin)

% Get the gridfile
grid = gridfile(sprintf('tref-%s.grid', cfrName));
meta = grid.metadata;

% Get each volcanic event, preceding 5 years, and following year
[~, loadTime] = ismember(volcYears(:)', meta.time);
adjust = (-nAnomaly:1)';
loadTime = loadTime + adjust;
loadTime = loadTime(:);
extra = meta.lat>=20;

% Load the data. Average any runs.
[volc, meta] = grid.load(["lat", "lon", "time", "run"], {extra, [], loadTime, []});
volc = mean(volc, 4);

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

% Require a minimum number of reconstructed eruptions
hasvals = sum(~isnan(volc(:,:,1,:)),4);
remove = hasvals < nMin;
remove = repmat(remove, [1 1 2 nVolc]);
volc(remove) = NaN;

% Take the composite mean
volc = nanmean(volc, 4);

% Save
saveName = sprintf('volcanic-composite-%s.mat', cfrName);
save(saveName, 'volc', 'volcYears', 'nAnomaly', 'meta');

end