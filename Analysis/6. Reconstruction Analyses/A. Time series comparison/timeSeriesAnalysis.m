function[] = timeSeriesAnalysis

% Organize time series in a structure
ts = struct;

% Load the DA time series
da = load('ensemble-reconstruction.mat');
latBounds = da.recon.ts.latBounds;
ts.da.years = da.years;
ts.da.ts = da.recon.ts.ts;
ts.da.Umodel = da.recon.ts.Umodel;
ts.da.Uposterior = da.recon.ts.Uposterior;

% Get the NTREND-PPR grid
ppr = gridfile('tref-ntrend.grid');
nLon = numel(ppr.metadata.lon);
half = nLon/2;
lon360 = [half+1:nLon, 1:half];
[ppr, pprMeta] = ppr.load("lon", {lon360} );
neg = pprMeta.lon<0;
pprMeta.lon(neg) = pprMeta.lon(neg) + 360;

% Use a frozen grid based on RE screening from 1000 CE
y1000 = find(pprMeta.time==1000);
screen = isnan(ppr(:,:,y1000));
screen = repmat(screen, [1 1 numel(pprMeta.time)]);
ppr(screen) = NaN;

% Take the spatial anomaly
anom = ismember(pprMeta.time, da.anomalyYears);
ppr = ppr - mean(ppr(:,:,anom),3);

% Get the time series weights
weights = repmat(cosd(pprMeta.lat'), [numel(pprMeta.lon), 1, numel(pprMeta.time)]);
weights(:, pprMeta.lat<latBounds(1) | pprMeta.lat>latBounds(2), :) = 0;
weights(screen) = NaN;

% Get the PPR time series. Take the time series anomaly
pprTS = nansum(weights .* ppr, [1 2]) ./ nansum(weights, [1 2]);
pprTS = permute(pprTS, [3 2 1]);
pprTS = pprTS - mean(pprTS(anom));

% Organize the PPR time series
ts.ppr.ts = pprTS;
ts.ppr.years = pprMeta.time;

% Load the BE target grid
be = ensemble('be.ens');
T = be.load;

% BE spatial anomaly
years = year(be.metadata.variable('T', 'time'));
anom = ismember(years, da.anomalyYears);
T = T - mean(T(:,anom),2);

% BE time series
weights = tsWeights('be', da.recon.ts.latBounds);
weights = repmat(weights, [1 size(T,2)]);
weights(isnan(T)) = NaN;
beTS = nansum(T.*weights, 1) ./ nansum(weights, 1);

% Time series anomaly
beTS = beTS - mean(beTS(anom));

% Organize BE output
ts.be.ts = beTS;
ts.be.years = years;

% Get the running standard deviations
k = 31;
ts.da.std = movstd(ts.da.ts, k, 'Endpoints', 'fill');
ts.ppr.std = movstd(ts.ppr.ts, k, 'Endpoints', 'fill');

% Save
save('time-series.mat', 'ts');

end

