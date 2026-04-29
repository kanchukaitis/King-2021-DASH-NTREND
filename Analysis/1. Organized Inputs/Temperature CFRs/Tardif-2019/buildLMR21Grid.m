function[] = buildLMR21Grid
%% Builds the gridfile for the LMR2.1 temperature reconstruction

% Get the metadata
file = 'air_MCruns_ensemble_mean_LMRv2.1.nc';
lon = ncread(file,'lon');
lat = ncread(file,'lat');
time = (0:2000)';
run = (1:20)';

% Initialize the gridfile
meta= gridfile.defineMetadata('lat',lat,'lon',lon,'time',time,'run',run);
dimOrder = ["lon","lat","run","time"];
atts = struct('season','annual','Unit','K');

% Add data
grid = gridfile.new('tref-lmr21.grid', meta, atts, true);
grid.add('nc', file, 'air', dimOrder, meta, 'convert', [1 -273.15] );

end

