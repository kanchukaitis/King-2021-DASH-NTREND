function[] = buildCSIROtas
%% Builds a gridfile for the CSIRO temperature data

% Get the output files
file1 = 'tas_Amon_CSIRO-Mk3L-1-2_past1000_r1i1p1_085101-185012.nc';
file2 = 'tas_Amon_CSIRO-Mk3L-1-2_historical_r1i1p1_185101-200012.nc';

% Get metadata and initialize grid
lat = ncread(file1,'lat');
lon = ncread(file2,'lon');
time = datetime(851,1,15):calmonths(1):datetime(2000,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-csiro.grid',gmeta,[],true);

% Add last1000 data
pi = year(gmeta.time) <= 1850;
meta = gmeta;
meta.time = gmeta.time(pi);
grid.add( 'nc', file1, 'tas', ["lon","lat","time"], meta);

% Add historical data
meta.time = gmeta.time(~pi);
grid.add( 'nc', file2, 'tas', ["lon","lat","time"], meta );

end