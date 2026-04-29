function[] = buildZhuGrid
%% Builds a gridfile for the Zhu et al 2020 reconstructions

% Get the metadata
f = 'job_r00.nc';
lat = ncread(f, 'lat');
lon = ncread(f, 'lon');
year = ncread(f, 'year');
run = (1:50)';

% Initialize the gridfile
meta = gridfile.defineMetadata('lat',lat,'lon',lon,'time',year,'run',run);
grid = gridfile.new('tref-zhu.grid', meta, [], true);

% Add the data from each run
dimOrder = ["lon","lat","time"];
for k = 0:49
    meta.run = k+1;
    f = sprintf('job_r%02.f.nc', k);
    grid.add('nc', f, "tas_sfc_Amon", dimOrder, meta);
end

end