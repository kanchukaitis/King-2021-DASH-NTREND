function[] = regress_NTREND_CRU
% Regress NTREND against CRU

% Get the ntrend and cru datasets
ntrend = gridfile('ntrend.grid');
records = ntrend.load(["coord", "time"]);
ntrend = ntrend.metadata;
cru = load('cru-at-ntrend.mat');

% Don't use years past 2005. This way, the pseudo-proxies and CRU use the
% same years
use = cru.years <= 2005;
cru.T = cru.T(:, use);
cru.years = cru.years(use);

% Preallocate
nSite = size(ntrend.coord,1);
intercept = NaN(nSite, 1);
slope = NaN(nSite, 1);
R = NaN(nSite, 1);
years = cell(nSite, 1);

% Get the record and cru data for each site
for s = 1:nSite
    disp(s);
    tree = records(s,:);
    T = cru.T(s,:);
    
    % Get the overlapping years of the two records
    years{s} = intersect( cru.years(~isnan(T)), ntrend.time(~isnan(tree)) );
    tree = tree(ismember(ntrend.time, years{s}));
    T = T(ismember(cru.years, years{s}));
    
    % Do the regression
    X = [ones(numel(years{s}), 1), T'];
    [slope(s), intercept(s), R(s)] = regression(X, tree');
end

% Save
save('ntrend-regression.mat', 'slope','intercept','R','years');

end