function[loc] = bestPseudoLoc(targetName, priorName)
%% Returns the best pseudo-proxy localization radius for a pseudo-proxy assimilation

name = sprintf('pseudoLocSkill-%s_target-%s_prior.mat', targetName, priorName);
out = load(name);
loc = median(out.bestLoc);

end