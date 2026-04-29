function[] = buildGlobalPrior(name)
%% Builds the prior for a given model

% Get the associated gridfile
gridName = sprintf('tref-%s.grid', name);
grid = gridfile(gridName);

% Find MJJA in the Northern hemisphere
meta = grid.metadata;
may = month(meta.time)==5;

% Design the state vector
sv = stateVector(name);
sv = sv.add('T', gridName);
sv = sv.design('T', "time", false, may);
sv = sv.mean('T', 'time', 0:3);

% Build
nEns = sum(may);
ensName = sprintf('%s-global.ens', name);
sv.build(nEns, false, ensName, true);

end