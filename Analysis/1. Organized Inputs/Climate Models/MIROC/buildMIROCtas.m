function[] = buildMIROCtas
%% Builds a gridfile for MIROC temperature data

% Get the output files
file1 = 'tas_Amon_MIROC-ESM_past1000_r1i1p1_085001-184912.nc';
file2 = 'tas_Amon_MIROC-ESM_historical_r1i1p1_185001-200512.nc';

% Get metadata and initialize the grid
lat = ncread(file1,'lat');
lon = ncread(file2,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-miroc.grid',gmeta,[],true);

% Add the past1000 data
pi = year(gmeta.time) < 1850;
meta = gmeta;
meta.time = gmeta.time(pi);
grid.add( 'nc', file1, 'tas', ["lon","lat","time"], meta);

% Add the historical data
meta.time = gmeta.time(~pi);
grid.add( 'nc', file2, 'tas', ["lon","lat","time"], meta );

end