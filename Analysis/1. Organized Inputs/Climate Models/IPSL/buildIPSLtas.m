function[] = buildIPSLtas
%% Builds a gridfile for the IPSL temperature data

% Get metadata and initialize the gridfile
file = 'tas_Amon_IPSL-CM5A-LR_past1000_r1i1p1_085001-104912.nc';
lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-ipsl.grid',gmeta,[],true);

% Add the data from each past1000 output file
for k = 850:200:1650
    file = sprintf('tas_Amon_IPSL-CM5A-LR_past1000_r1i1p1_%04.f01-%4.f12.nc', k, k+199);
    meta = gmeta;
    meta.time = ( datetime(k,1,15):calmonths(1):datetime(k+199,12,15) )';
    grid.add('nc', file, 'tas', ["lon","lat","time"], meta);
end

% Add the historical data
file = 'tas_Amon_IPSL-CM5A-LR_historical_r1i1p1_185001-200512.nc';
meta = gmeta;
meta.time = ( datetime(1850,1,15):calmonths(1):datetime(2005,12,15) )';
grid.add('nc', file, 'tas', ["lon","lat","time"], meta);

end