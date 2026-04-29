function[] = compareMethods(targetName, priorName)

% Load the PPR and DA skill
ppr = load(sprintf('ppr-%s_target-noisy-attrition-skill.mat', targetName));
da = load(sprintf('%s_target-%s_prior-noisy-attrition-skill.mat', targetName, priorName));

% Cycle through each metric, save difference in structure
delta = struct;
metrics = ["rho", "rmse", "ratio", "bias"];
for m = 1:numel(metrics)
    metric = metrics(m);
    
    % Load the two skill maps
    damap = median(da.spatial.(metric), 3);
    pprmap = ppr.spatial.(metric);
    
    % Match to the same grid. Save difference
    [damap, pprmap, meta] = matchGrids(damap, da.spatial.meta, pprmap, ppr.spatial.meta);
    delta.(metric) = damap - pprmap;
end

% Save
saveName = sprintf('DAvsPPR-%s_target-%s_prior.mat', targetName, priorName);
skillYears = ppr.skillYears;
save(saveName, 'delta', 'skillYears', 'meta');

end