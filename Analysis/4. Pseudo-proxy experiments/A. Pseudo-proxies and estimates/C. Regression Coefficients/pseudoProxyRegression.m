function[] = pseudoProxyRegression(targetName)
%% Mimic the NTREND-CRU regression for the pseudo-proxies

% Get the pseudo-proxies, target temperature, ntrend metadata, and psm
pseudo = load(sprintf('%s-pseudoproxies.mat',targetName));
target = load(sprintf('%s-at-ntrend.mat', targetName));
psm = load('ntrend-regression.mat');

% Preallocate
nSite = size(pseudo.Yperfect,1);
nNoise = size(pseudo.Ynoisy,3);
perfect = struct('slope', NaN(nSite, 1), 'intercept', NaN(nSite,1), 'R', NaN(nSite, 1));
noisy = struct('slope', NaN(nSite,1,nNoise), 'intercept', NaN(nSite,1,nNoise), 'R', NaN(nSite,1,nNoise));

% Get the records and target data for each site
for s = 1:nSite
    disp(s);
    perfectTree = pseudo.Yperfect(s,:);
    noisyTree = pseudo.Ynoisy(s,:,:);
    T = target.T(s,:);

    % Use the same years as in the NTREND-CRU regression
    use = ismember(pseudo.years, psm.years{s});
    perfectTree = perfectTree(use);
    noisyTree = noisyTree(1,use,:);
    
    use = ismember(target.years, psm.years{s});
    T = T(use);
    
    % Get the regression independent variable
    X = [ones(numel(psm.years{s}),1), T'];
    
    % Do the perfect and noisy regressions
    [perfect.slope(s), perfect.intercept(s), perfect.R(s)] = regression(X, perfectTree');
    for k = 1:nNoise
        [noisy.slope(s,:,k), noisy.intercept(s,:,k), noisy.R(s,:,k)] = regression(X, noisyTree(:,:,k)');
    end
end

% Save
saveName = sprintf('%s-pseudo-psms.mat', targetName);
save(saveName, 'perfect', 'noisy');

end