function[] = buildNTRENDGrid
%% Build a gridfile for the NTREND network

% Get the metadata
f = 'ntrend.mat';
ntrend = load(f);
coord = [ntrend.lat, ntrend.lon];
time = ntrend.year;

% Record proxy attributes
atts = struct();
atts.name = ntrend.name;
atts.season = ntrend.season;
atts.type = ntrend.type;

% Initialize the grid file
meta = gridfile.defineMetadata('coord', coord, 'time', time);
grid = gridfile.new('ntrend.grid', meta, atts, true);

% Add the data
grid.add('mat', f, 'crn', ["time", "coord"], meta);

end