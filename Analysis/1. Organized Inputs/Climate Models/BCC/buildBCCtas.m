function[] = buildBCCtas
%% Build a gridfile for the BCC temperature output

% Get the files
file1 = 'tas_Amon_bcc-csm1-1_past1000_r1i1p1_085001-185012.nc';
file2 = 'tas_Amon_bcc-csm1-1_past1000_r1i1p1_185101-200012.nc';

% Define metadata and initialize the grid
lat = ncread(file1,'lat');
lon = ncread(file2,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2000,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-bcc.grid',gmeta,[],true);

% Add last millennium data
pi = year(gmeta.time) <= 1850;
meta = gmeta;
meta.time = gmeta.time(pi);
grid.add( 'nc', file1, 'tas', ["lon","lat","time"], meta);

% Add historical data
meta.time = gmeta.time(~pi);
grid.add( 'nc', file2, 'tas', ["lon","lat","time"], meta );

end