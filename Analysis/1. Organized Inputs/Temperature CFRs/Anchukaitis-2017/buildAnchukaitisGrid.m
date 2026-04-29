function[] = buildAnchukaitisGrid
%% Builds a gridfile for the Anchukaitis et al 2017 reconstruction

% Get the metadata
file = 'ntrend2017grid.nc';
lon = ncread(file,'longitude');
lat = ncread(file,'latitude');
time = ncread(file,'time');

% Initialize the gridfile
meta = gridfile.defineMetadata('lon',lon,'lat',lat,'time',time);
atts = struct('season','MJJA', 'units','c', 'anomaly', '1961-1990');
grid = gridfile.new('tref-ntrend.grid', meta, atts, true );

% Add the data
dimOrder = ["time","lat","lon"];
grid.add( 'nc', file, 't_filtered', dimOrder, meta, 'fill', -9999 );

end
