function[loc] = bestLoc(priorName)
%% Returns the best pseudo-proxy localization radius

out = load(sprintf('locRadius-%s_prior.mat', priorName));
loc = median(out.bestLoc);

end