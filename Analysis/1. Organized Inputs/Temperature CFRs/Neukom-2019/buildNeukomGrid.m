function[] = buildNeukomGrid
%% Builds a gridfile for the Neukom et al 2019 DA reconstruction

% Get the metadata
file = 'DA.nc';
lon = ncread(file,'lon');
lat = ncread(file,'lat');
run = (1:100)';
time = ncread(file,'time');

% Initialize the metadata
meta = gridfile.defineMetadata( 'lon', lon, 'lat', lat, 'run', run, 'time', time );
dimOrder = ["lon","lat","run","time"];
atts = struct('season','annual','units','K');

% Add the data
grid = gridfile.new('tref-neukomda.grid', meta, atts, true );
grid.add('nc', file, 'temp', dimOrder, meta, 'convert', [1 -273.15] );

end