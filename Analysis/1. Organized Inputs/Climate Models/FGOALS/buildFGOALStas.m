function[] = buildFGOALStas
%% Builds a gridfile for FGOALS temperature data

% Get metadata and initialize the grid
file = 'tas_Amon_FGOALS-gl_past1000_r1i1p1_100001-119912.nc';
lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = datetime(1000,1,15):calmonths(1):datetime(1999,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-fgoals.grid',gmeta,[],true);

% Add the data from each output file
for k = 1000:200:1800
    file = sprintf('tas_Amon_FGOALS-gl_past1000_r1i1p1_%4.f01-%4.f12.nc', k, k+199 );
    meta= gmeta;
    meta.time = gmeta.time( year(gmeta.time)>=k & year(gmeta.time)<k+200 );
    grid.add( 'nc', file, 'tas', ["lon","lat","time"], meta);
end

end