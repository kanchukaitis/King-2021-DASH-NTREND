function[] = buildBerkeleyGrid()
%% Builds a gridfile for the Berkeley temperature reanalysis

% Get the metadata
file = 'BE_Land_and_Ocean_LatLong1.nc';
lat = ncread(file,'latitude');
lon = ncread(file, 'longitude');
time = (datetime(1850,1,15):calmonths(1):datetime(2019,12,15))';

% Initialize the grid
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
atts = struct('Anomaly', '1951-1980', 'Units', 'C');
grid = gridfile.new('tref-be.grid', meta, atts);

% Add the data
dimOrder = ["lon","lat","time"];
grid.add( 'nc', file, 'temperature', dimOrder, meta );

end