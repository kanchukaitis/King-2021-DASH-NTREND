function[] = siteTemperatures(name)
%% Saves the optimal growing season temperature at the NTREND sites for a dataset

% Load the NTREND metadata
ntrend = gridfile('ntrend.grid');
ntrend = ntrend.metadata;

% Get the gridfile for the dataset
gridName = sprintf('tref-%s.grid',name);
grid = gridfile(gridName);
meta = grid.metadata;
years = unique(year(meta.time));

% Use ensembleMetadata to find closest gridpoints
sv = stateVector;
sv = sv.add('T', gridName);
sv = sv.design('T', 'time', 'ens');
ensMeta = ensembleMetadata(sv);

% Preallocate
nSite = size(ntrend.coord, 1);
nYear = numel(meta.time)/12;
T = NaN(nSite, nYear);

% Get the NTREND coordinates
for s = 1:nSite
    disp(s);
    coord = ntrend.coord(s,:);
    
    % Grid 18 is in the ocean for CRU. Adjust to nearest land cell
    if strcmp(ntrend.attributes.name(s), "Grid18") && strcmpi(name, 'cru')
        coord = [50.75, 143.75];
    end
    
    % Find the closest grid coordinate to the site
    closest = ensMeta.closestLatLon(coord);
    closest = ensMeta.rows(closest(1));
    lat = meta.lat==closest.lat(1);
    lon = meta.lon==closest.lon(1);
    
    % Load the data at the site for all months of the year
    Tall = grid.load(["time","lon","lat"], {[], lon, lat});
    
    % Reshape to monthly. Get the mean in the optimal growing season
    Tall = reshape(Tall, [12 nYear]);
    season = ntrend.attributes.season{s};
    Tall = Tall(season,:);
    T(s,:) = mean(Tall,1);
end

% Convert MPI and CESM to celsius
if ~strcmpi(name, 'cru')
    T = T - 273.15;
end

% Save
saveName = sprintf('%s-at-ntrend.mat', name);
save(saveName, 'T', 'years');

end