function[] = buildCESMtas
%% Builds a gridfile for the CESM temperature data

% Get the output files
file1 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.085001-184912.nc';
file2 = 'b.e11.BLMTRC5CN.f19_g16.002.cam.h0.TREFHT.185001-200512.nc';

% Get metadata and initialize the grid
lat = ncread(file1,'lat');
lon = ncread(file1,'lon');
time = (datetime(850,1,15):calmonths(1):datetime(2005,12,15))';
pi = year(time)<1850;

meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',time);
grid = gridfile.new('tref-cesm.grid', meta,[], true);

% Add the data from each file
dimOrder = ["lon","lat","time"];
meta.time = time(pi);
grid.add('nc', file1, 'TREFHT', dimOrder, meta);
meta.time = time(~pi);
grid.add('nc', file2, 'TREFHT', dimOrder, meta);

end