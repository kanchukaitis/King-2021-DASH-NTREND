function[] = estimateProxies(name, anomalyYears)
%% Generates the proxy estimates for a model

% Load the gridfile, prior, ntrend, cru, and psm statistics
grid = gridfile(sprintf('tref-%s.grid', name));
meta = grid.metadata;

ens = ensemble(sprintf('%s.ens',name));
ensMeta = ens.metadata;

ntrend = gridfile('ntrend.grid');
records = ntrend.load;
ntrend = ntrend.metadata;

psm = load('ntrend-regression.mat');

% Preallocate the estimates
nSite = size(ntrend.coord, 1);
Ye = NaN(nSite, ensMeta.nEns);

% Find the closest model grid to each site
for s = 1:nSite
    disp(s);
    closest = ensMeta.closestLatLon(ntrend.coord(s,:));
    closest = ensMeta.rows(closest(1));
    lat = meta.lat==closest.lat;
    lon = meta.lon==closest.lon;
    
    % Load the data at the closest site.
    T = grid.load(["time","lat","lon"], {[], lat, lon});
    
    % Get the mean in the optimal growing season
    season = ntrend.attributes.season{s};
    T = reshape(T, [12 ensMeta.nEns]);
    T = T(season, :);
    T = mean(T,1);
    
    % Use the PSM statistics to calculate Ye
    Ye(s,:) = psm.intercept(s) + psm.slope(s) * T;
end

% Bias correct the mean in the anomaly period to match NTREND
anom = ismember(ntrend.time, anomalyYears);
targetMean = mean(records(:,anom), 2);

modelYears = unique(year(meta.time));
anom = ismember(modelYears, anomalyYears);
Ymean = mean(Ye(:,anom), 2);

Ye = Ye - Ymean + targetMean;

% Save
saveName = sprintf('%s-ntrend-estimates.mat', name);
time = modelYears;
save(saveName, 'Ye', 'time');

end