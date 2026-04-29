function[] = pseudoProxies(targetName, nNoise)

% Load psm regression, and target at the proxy sites
psm = load('ntrend-regression.mat');
target = load(sprintf('%s-at-ntrend.mat', targetName));
years = target.years;
[nSite, nYear] = size(target.T);

% Get the perfect (no-noise) pseudo-proxies
Yperfect = NaN(nSite, nYear);
for s = 1:nSite
    Yperfect(s,:) = psm.intercept(s) + psm.slope(s) * target.T(s,:); 
end    

% Generate noisy pseudo-proxies
rng('default');
Rstd = sqrt(psm.R);
noise = Rstd .* randn(nSite, nYear, nNoise);
Ynoisy = Yperfect + noise;

% Save
saveName = sprintf('%s-pseudoproxies.mat', targetName);
save(saveName, 'Yperfect','Ynoisy','years');

end