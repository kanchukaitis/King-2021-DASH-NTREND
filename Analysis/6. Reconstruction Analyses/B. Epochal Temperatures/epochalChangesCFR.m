function[] = epochalChangesCFR(cfrName, mcaYears, liaYears)

% Get the gridfile
grid = gridfile(sprintf('tref-%s.grid', cfrName));
meta = grid.metadata;

% Get the mca and lia periods, and the extratropical area
mca = ismember(meta.time, mcaYears);
lia = ismember(meta.time, liaYears);
extra = meta.lat>=30;

% Load the data for the two periods.
[mca, meta] = grid.load(["lat","lon","time","run"], {extra, [], mca, []});
lia = grid.load(["lat","lon","time","run"], {extra, [], lia, []});

% Take the time means and get the difference
mca = mean(mca, [3 4]);
lia = mean(lia, [3 4]);
delta = mca - lia;

% Save
saveName = sprintf('MCA-LIA-%s.mat', cfrName);
save(saveName, 'delta', 'mcaYears','liaYears', 'meta');

end
