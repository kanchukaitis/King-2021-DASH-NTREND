function[] = exportReconstruction(priorName)

% Load the reconstruction and ensemble metadta
ens = ensemble(sprintf('%s.ens', priorName));
ensMeta = ens.metadata;
out = load(sprintf('%s-reconstruction.mat', priorName));

% Regrid the spatial fields
[T, Tmeta] = ensMeta.regrid(out.out.Amean, 'T', ["lon","lat"]);
variance = ensMeta.regrid(out.out.Avar, 'T', ["lon","lat"]);

% Also get the time series and its variance
ts = out.ts';
tsvar = var(out.out.ts)';

% Basic file schema
schema = struct();
schema.Name = '/';
schema.Format = 'netcdf4';

% Next, build the dimension schema
dims = {'lon','lat','time'};
length = [numel(Tmeta.lon), numel(Tmeta.lat), numel(out.years)];
dimensions = struct;
for d = 1:numel(dims)
    dimensions(d).Name = dims{d};
    dimensions(d).Length = length(d);
end
schema.Dimensions = dimensions;

% Then, the variable schema
vars = {'T', 'T_uncertainty', 'lon', 'lat', 'time', 'ts', 'ts_uncertainty'};
vardims = {["lon","lat","time"], ["lon","lat","time"], "lon", "lat", "time","time","time"};
description = {'Surface temperature anomaly', 'Surface temperature anomaly uncertainty',...
    'longitude', 'latitude', 'time', 'Mean extratropical temperature anomaly', ...
    'Mean extratropical temperature anomaly uncertainty'};
calculation_details = {'Posterior mean', 'Posterior variance', [], [], [], 'Posterior mean of the latitude-weighted spatial averages', ...
    'Posterior variance of the latitude-weighted spatial averages'};
units = {'Celsius', 'Celsius^2', 'degrees_north', 'degrees_east', 'Year_CE', 'Celsius', 'Celsius^2'};
anomaly = {[1951 1980], [1951 1980], [], [], [], [1951 1980], [1951 1980]};
latitude_bounds = {[],[],[],[],[],[30 90], [30 90]};
season = {'MJJA', 'MJJA', [], [], [], 'MJJA', 'MJJA'};
variables = struct;
for v = 1:numel(vars)
    variables(v).Name = vars{v};
    d = ismember(dims, vardims{v});
    variables(v).Dimensions = dimensions(d);
    variables(v).Datatype = 'double';
    
    % Include variable attributes
    variables(v).Attributes = struct;
    variables(v).Attributes(1).Name = 'Units';
    variables(v).Attributes(1).Value = units{v};
    variables(v).Attributes(2).Name = 'description';
    variables(v).Attributes(2).Value = description{v};
    if ~isempty(season{v})
        variables(v).Attributes(3).Name = 'Calculation_details';
        variables(v).Attributes(3).Value = calculation_details{v};
        variables(v).Attributes(4).Name = 'Season';
        variables(v).Attributes(4).Value = season{v};
    end
    if ~isempty(anomaly{v})
        variables(v).Attributes(5).Name = 'Anomaly';
        variables(v).Attributes(5).Value = anomaly{v};
    end
    if ~isempty(latitude_bounds{v})
        variables(v).Attributes(6).Name = 'latitude_bounds';
        variables(v).Attributes(6).Value = latitude_bounds{v};
    end
end
schema.Variables = variables;

% Create the NetCDF file
file = sprintf('%s-reconstruction.nc', priorName);
ncwriteschema(file, schema);

% Write the variables
ncwrite(file, 'T', T);
ncwrite(file, 'T_uncertainty', variance);
ncwrite(file, 'lon', Tmeta.lon);
ncwrite(file, 'lat', Tmeta.lat);
ncwrite(file, 'time', out.years);
ncwrite(file, 'ts', ts);
ncwrite(file, 'ts_uncertainty', tsvar);

end
