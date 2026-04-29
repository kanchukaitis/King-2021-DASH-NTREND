function[] = buildMPItas
%% Builds a gridfile for MPI temperature data

% Get the files
f1 = 'tas_Amon_MPI-ESM-P_past1000_r1i1p1_085001-184912.nc';
f2 = 'tas_Amon_MPI-ESM-P_historical_r1i1p1_185001-200512.nc';

% Get metadata and intitialize the grid
lat = ncread(f1, 'lat');
lon = ncread(f2, 'lon');
time = (datetime(850,1,15) : calmonths(1) : datetime(2005,12,15))';
meta = gridfile.defineMetadata( 'lat', lat, 'lon', lon, 'time', time );
grid = gridfile.new('tref-mpi.grid', meta,[],true);

% Add the past1000 data
dimOrder = ["lon","lat","time"];
meta.time = time(1:12000);
grid.add( 'nc', f1, 'tas', dimOrder, meta );

% Add the historical data
meta.time = time(12001:end);
grid.add( 'nc', f2, 'tas', dimOrder, meta );

end