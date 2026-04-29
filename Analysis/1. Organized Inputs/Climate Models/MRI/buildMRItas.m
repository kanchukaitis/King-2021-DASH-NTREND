function[] = buildMRItas
%% Builds a gridfile for MRI temperature data

% Get metadata and initialize the grid
file = 'tas_Amon_MRI-CGCM3_past1000_r1i1p1_085001-134912.nc';
lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-mri.grid',gmeta,[],true);

% Add the data from each past1000 output data
for k = 850:500:1350
    file = sprintf('tas_Amon_MRI-CGCM3_past1000_r1i1p1_%04.f01-%04.f12.nc', k, k+499);
    meta = gmeta;
    meta.time = ( datetime(k,1,15):calmonths(1):datetime(k+499,12,15) )';
    grid.add('nc', file, 'tas', ["lon","lat","time"], meta);
end

% Add historical data
file = 'tas_Amon_MRI-CGCM3_historical_r1i1p1_185001-200512.nc';
meta = gmeta;
meta.time = ( datetime(1850,1,15):calmonths(1):datetime(2005,12,15) )';
grid.add('nc', file, 'tas', ["lon","lat","time"], meta);

end