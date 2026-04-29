function[] = proxyKnockouts(priorName, loc)

% Load the proxies and uncertainty
ntrend = gridfile('ntrend.grid');
D = ntrend.load;
ntrend = ntrend.metadata;

regression = load('ntrend-regression.mat');
R = regression.R;

% Proxy estimates are also the prior
Ye = load(sprintf('%s-cru-estimates.mat', priorName));
Ye = Ye.Ye;

% Remove any ensemble members with NaN
delete = any(isnan(Ye),1);
Ye(:,delete) = [];

% Preallocate the reconstructed proxy records
[nSite, nTime] = size(D);
Yrecon = NaN(nSite, nTime);
Yvar = NaN(nSite, nTime);

% Remove one proxy from each experiment
nSite = size(D,1);
for s = 1:nSite
    use = [1:s-1, s+1:nSite]

    % Run a kalman filter for each knockout
    kf = kalmanFilter;
    kf = kf.prior( Ye(s,:) );
    kf = kf.observations(D(use,:), R(use));
    kf = kf.estimates( Ye(use,:) );
    [wloc, yloc] = dash.localizationWeights('gc2d', ntrend.coord(s,:), ntrend.coord(use,:), loc);
    kf = kf.localize(wloc, yloc);
    out = kf.run;

    % Save the output
    Yrecon(s,:) = out.Amean;
    Yvar(s,:) = out.Avar;
end
years = ntrend.time;
saveName = sprintf('%s-proxy-knockouts.mat', priorName);
save(saveName, 'Yrecon', 'Yvar', 'years');

end
