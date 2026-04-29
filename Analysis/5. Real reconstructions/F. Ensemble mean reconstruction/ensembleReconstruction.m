function[] = ensembleReconstruction(priorNames, anomalyYears)

% Cycle through the lat-lon coordinates of each prior
nPrior = numel(priorNames);
minLat = Inf;
minLon = Inf;
for p = 1:nPrior
    ens = ensemble(sprintf('%s.ens', priorNames(p)));
    meta = ens.metadata.metadata.T.state;
    
    % Record the lowest resolution for each coordinate
    if numel(meta.lat) < minLat
        minLat = numel(meta.lat);
        lats = meta.lat;
    end
    if numel(meta.lon) < minLon
        minLon = numel(meta.lon);
        lons = meta.lon;
    end
end

% Get time steps
recon = load(sprintf('%s-reconstruction.mat', priorNames(1)));
years = recon.years;
nTime = numel(years);

% Preallocate the spatial grids and time series
T = NaN(minLat, minLon, nTime, nPrior);
Tmeta = struct('lat', lats, 'lon', lons);
Tvar = zeros(minLat, minLon, nTime);

ts = NaN(nTime, nPrior);
tsVar = NaN(nTime, nPrior);

% Load each reconstruction. Get the spatial map and variance
for p = 1:nPrior
    recon = load(sprintf('%s-reconstruction.mat', priorNames(p)));
    A = recon.out.Amean;
    Avar = recon.out.Avar;
    
    % Regrid
    ens = ensemble(sprintf('%s.ens', priorNames(p)));
    [A, Ameta] = ens.metadata.regrid(A, 'T', ["lat", "lon"]);
    Avar = ens.metadata.regrid(Avar, 'T', ["lat", "lon"]);
    
    % Match to lowest resolution.
    Avar = matchGrids(Avar, Ameta, T(:,:,:,p), Tmeta);
    A = matchGrids(A, Ameta, T(:,:,:,p), Tmeta);
    
    % Redo spatial anomalies for regridded product
    anom = ismember(recon.years, anomalyYears);
    A = A - mean(A(:,:,anom), 3);
    
    % Store the low-res spatial resolution. Sum the posterior variances.
    T(:,:,:,p) = A;
    Tvar = Tvar + Avar;
    
    % Also collect the time series and time series variance for each
    % reconstruction
    ts(:,p) = recon.ts;
    tsVar(:,p) = var(recon.out.ts, [], 1);
end

% Get the spatial uncertainties
Uposterior = 2*sqrt(Tvar/nPrior);
Umodel = 2*std(T,[],4);

% Get the ensemble spatial reconstruction. Redo the anomalies
T = mean(T,4);
T = T - mean(T(:,:,anom), 3);

% Organize the spatial ensemble
spatial = struct('T', T, 'meta', Tmeta, 'Uposterior', Uposterior, 'Umodel', Umodel);

% Get the time series uncertainties
Umodel = 2*std(ts, [], 2);
Uposterior = 2*sqrt( mean(tsVar, 2) );

% Get the ensemble time series. Redo the anomaly
ts = mean(ts, 2);
ts = ts - mean(ts(anom));

% Organize the time series ensemble
ts = struct('ts', ts, 'Uposterior', Uposterior, 'Umodel', Umodel, 'latBounds', recon.latBounds);

% Save
years = recon.years;
recon = struct('ts', ts, 'spatial', spatial);
save('ensemble-reconstruction.mat', 'recon', 'years', 'anomalyYears', 'priorNames');

end