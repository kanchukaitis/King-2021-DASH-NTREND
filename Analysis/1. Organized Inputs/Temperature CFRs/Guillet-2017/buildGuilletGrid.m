function[] = buildGuilletGrid
%% Builds a gridfile for the Guillet et al 2017 reconstruction

% Get the metadata
file = 'Guillet_et_al_2017_500-2012.nc';
lon = ncread(file,'longitude');
lat = ncread(file,'latitude');
time = ncread(file,'Years');

% Initialize the gridfile
atts = struct('season','JJA','units','C','anomaly','30-yr climatology');
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
dimOrder = ["lon","lat","time"];

% Add the data
grid = gridfile.new('tref-guillet.grid', meta, atts, true );
grid.add( 'nc', file, 'JJA_temperature_anomaly', dimOrder, meta );

end


