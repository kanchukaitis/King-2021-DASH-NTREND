function[weights] = tsWeights(name, latBounds)
%% Gets latitude weights for grid cells used to compute spatial-mean time series

% Load the ensemble metadta
ens = ensemble(sprintf('%s.ens', name));
lats = ens.metadata.dimension('lat');
use = lats>latBounds(1) & lats<latBounds(2);
weights = cosd(lats) .* use;

end