function[] = figure1
%% Plots the map of the NTREND sites

% Load NTREND metadata
ntrend = gridfile('ntrend.grid');
records = ntrend.load;
ntrend = ntrend.metadata;

% Set non RW or MXD as "MIX"
type = ntrend.attributes.type;
type(~ismember(type, ["RW", "MXD"])) = "MIX";

% Get the starting year of each record
nSite = size(records,1);
start = NaN(nSite,1);
for s = 1:nSite
    start(s) = find(~isnan(records(s,:)), 1, 'first');
end
startYear = ntrend.time(start);

% Initialize map
figure('Position',[643 2 637 634]);
m_proj('stereo', 'lat', 90, 'lon', -30, 'rad', 60);
m_coast;
hold on

% Colormap
cmap = cbrew('redblue',22);
cmap = cmap(1:10,:);
binEnd = 850:100:1750;

% Site markers
% circle: RW
% square: MXD
% diamond: MIX
for s = 1:nSite
    switch type(s)
        case "RW"
            mark = 'o';
        case "MXD"
            mark = 's';
        case "MIX"
            mark = 'v';
        otherwise
            error('Unrecognized type');
    end
    
    % Marker color is based on starting year
    k = find( startYear(s)<binEnd, 1 );
    color = cmap(k,:);
    
    % Plot
    m_scatter(ntrend.coord(s,2), ntrend.coord(s,1), 75, 'k', mark, 'MarkerFaceColor', color);
end
m_grid;

% Build the legend
prw = scatter(NaN, NaN, NaN, 'k', 'o', 'MarkerFaceColor', cmap(5,:) );
pmxd = scatter(NaN, NaN, NaN, 'k', 's', 'MarkerFaceColor', cmap(5,:) );
pmix = scatter(NaN, NaN, NaN, 'k', 'v', 'MarkerFaceColor', cmap(5,:) );
[l, icons] = legend([prw, pmxd, pmix], 'TRW','MXD','Mixed', 'Fontsize',16);

% Label the colorbar
colormap(cmap);
c = colorbar;
c.Label.String = 'First Year in Record (CE)';
set(gca,'clim',[750 1750],'Fontsize',14);

% Tweak colorbar location
f = gcf;
ax = f.Children(3);
ax.Position(1) = .08;
cbar = f.Children(1);
cbar.Position(1) = .82;
l.Position = [0.0319 0.7182 0.1695 0.1356];

% Tweak the legend icon sizes
for k = 4:6
    icons(k).Children.MarkerSize = 10;
end

% Export to .eps
name = 'figure1.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end