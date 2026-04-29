function[] = buildCCSM4tas
%% Builds a gridfile for the CCSM4 temperature data

% Trim the first year from the CCSM4 historical data to avoid duplicate 1850
file = 'tas_Amon_CCSM4_historical_r1i1p1_185001-200512.nc';
tas = ncread(file, 'tas');
tas(:,:,1:12) = [];
save('CCSM4_historical_tas.mat', 'tas', '-v7.3');

% Get the files
file1 = 'tas_Amon_CCSM4_past1000_r1i1p1_085001-185012.nc';
file2 = 'CCSM4_historical_tas.mat';

% Get metadata and initialize grid
lat = ncread(file1,'lat');
lon = ncread(file1,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-ccsm4.grid',gmeta,[],true);

% Add past1000 data
pi = year(gmeta.time) <= 1850;
meta = gmeta;
meta.time = gmeta.time(pi);
grid.add( 'nc', file1, 'tas', ["lon","lat","time"], meta);

% Add historical data
meta.time = gmeta.time(~pi);
grid.add( 'mat', file2, 'tas', ["lon","lat","time"], meta );

end