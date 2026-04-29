function[] = buildHadCM3tas
%% Builds a gridfile for HadCM3 temperature data

% Get metadata and initialize the grid
file = 'tas_Amon_HadCM3_past1000_r1i1p1_085001-185012.nc';
lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = datetime(850,1,15):calmonths(1):datetime(2005,12,15);
gmeta = gridfile.defineMetadata( 'lat',lat,'lon',lon,'time', time');
grid = gridfile.new('tref-hadcm3.grid',gmeta,[],true);

% Add in the past1000 data
meta = gmeta;
meta.time = gmeta.time(1:12012);
grid.add('nc', file, 'tas', ["lon","lat","time"], meta);

% Add data from each historical output file
for k = 1859:25:1984
    file = sprintf('tas_Amon_HadCM3_historical_r1i1p1_%4.f12-%4.f11.nc', k, k+25 );
    meta.time = ( datetime(k,12,15):calmonths(1):datetime(k+25,11,15) )';
    
    if k==1984
        file = sprintf('tas_Amon_HadCM3_historical_r1i1p1_%4.f12-%4.f12.nc', k, k+21 );
        meta.time = ( datetime(k,12,15):calmonths(1):datetime(2005,12,15) )';
    end
    
    grid.add( 'nc', file, 'tas', ["lon","lat","time"], meta );
end

end