function[] = buildCRUGrid
%% Builds a gridfile for the CRU-TS 4.01 temperature reanalysis

% Get the metadata
f = 'cru_ts4.01.1901.2016.tmp.dat.nc';
lon = ncread(f,'lon');
lat = ncread(f,'lat');
time = (datetime(1901,1,15):calmonths(1):datetime(2016,12,15))';

% Get the land mask
t1 = ncread(f,'tmp',[1 1 1], [Inf, Inf, 1]);
land = ~isnan(t1);

% Initialize the gridfile
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
atts = struct('land',land);
grid = gridfile.new('tref-cru.grid',meta,atts);

% Add the data
dimOrder = ["lon","lat","time"];
grid.add('nc', f, 'tmp', dimOrder, meta );

end