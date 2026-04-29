function[] = exportEnsembleMean

% Load the ensemble mean reconstruction
out = load('ensemble-reconstruction.mat');
recon = out.recon;

% Get the spatial fields
T = permute(recon.spatial.T, [2 1 3]);
Tpost = permute(recon.spatial.Uposterior, [2 1 3]);
Tmodel = permute(recon.spatial.Umodel, [2 1 3]);

% Get the time series fields
ts = recon.ts.ts;
tspost = recon.ts.Uposterior;
tsmodel = recon.ts.Umodel;

% Get the metadata
lat = recon.spatial.meta.lat;
lon = recon.spatial.meta.lon;
time = out.years;

% Initialize the file schema
schema = struct();
schema.Name = '/';
schema.Format = 'netcdf4';

% Build the dimension schema
dims = {'lon','lat','time'};
length = [numel(lon), numel(lat), numel(time)];
dimensions = struct;
for d = 1:numel(dims)
    dimensions(d).Name = dims{d};
    dimensions(d).Length = length(d);
end
schema.Dimensions = dimensions;

% Next the variable schema
vars = {'lon', 'lat', 'time', ...
        'T', 'T_model_uncertainty', 'T_posterior_uncertainty', ...
        'ts', 'ts_model_uncertainty', 'ts_posterior_uncertainty'};
vardims = {"lon","lat","time", ...
          ["lon","lat","time"],  ["lon","lat","time"],  ["lon","lat","time"], ...
          "time", "time", "time"};
           
description = {'longitude','latitude','time', ...
    'Surface temperature anomaly', 'Surface temperature anomaly, model uncertainty', ...
    'Surface temperature anomaly, posterior uncertainty', 'Mean extratropical temperature anomaly', ...
    'Mean extratropical temperature anomaly, model uncertainty', ...
    'Mean extratropcial temperature anomaly, posterior uncertainy'};

details = {[],[],[], 'Multi-model mean of posterior means', 'Multi-model variance of posterior means', ...
    'Multi-model mean of posterior variances', 'Multi-model mean of posterior means of latitude-weighted spatial averages',...
    'Multi-model variance of posterior means of latitude-weighted spatial averages',...
    'Multi-model mean of posterior variances of latitude-weighted spatial averages'};
    
units = {'degrees_east','degrees_north','Year_CE','Celsius','Celsius^2','Celsius^2',...
    'Celsius','Celsius^2','Celsius^2'};

season = [repmat({[]},[1 3]), repmat({'MJJA'}, [1 6])];
latitude = [repmat({[]},[1 6]), repmat({[30 90]}, [1 3])];
anomaly = [repmat({[]},[1 6]), repmat({[1951 1980]}, [1 3])];

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
        variables(v).Attributes(3).Value = details{v};
        variables(v).Attributes(4).Name = 'Season';
        variables(v).Attributes(4).Value = season{v};
    end
    if ~isempty(anomaly{v})
        variables(v).Attributes(5).Name = 'Anomaly';
        variables(v).Attributes(5).Value = anomaly{v};
    end
    if ~isempty(latitude{v})
        variables(v).Attributes(6).Name = 'latitude_bounds';
        variables(v).Attributes(6).Value = latitude{v};
    end
end
schema.Variables = variables;

% Create the NetCDF file
file = 'ensemble-mean-reconstruction.nc';
ncwriteschema(file, schema);

% Write the variables
values = {lon, lat, time, T, Tpost, Tmodel, ts, tspost, tsmodel};
for v = 1:numel(values)
    ncwrite(file, vars{v}, values{v});
end

end