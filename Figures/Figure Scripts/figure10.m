function[] = figure10
%% Plots the 1258 and 1601 events for the DA ensemble-mean reconstruction

% Load the NTREND data
ntrend = gridfile('ntrend.grid');
records = ntrend.load;
ntrend = ntrend.metadata;

% Label type as RW, MXD, or MIX
types = ntrend.attributes.type;
types(~ismember(types, ["RW","MXD"])) = "MIX";

% Get the DA maps and metadata
da1 = load('1258-event.mat');
da2 = load('1601-event.mat');
maps = {da1.T, da1.Uposterior, da1.Umodel; ...
        da2.T, da2.Uposterior, da2.Umodel};
meta = da1.meta;

% Get the NTREND sites for each eruption
sites = cell(2,1);
sites{1} = find(~isnan(records(:, ntrend.time==da1.volcYear)));
sites{2} = find(~isnan(records(:, ntrend.time==da2.volcYear)));

% Create a full screen figure
figPos = [123 164 761 472];
fig = figure('position', figPos);

% Get the edges of the workspace
lWidth = 0.08;
lHeight = .04;
cWidth = .3;
cHeight = .15;

leftEdge = lWidth;
rightEdge = 1;
figWidth = rightEdge - leftEdge;

topEdge = 1 - cHeight;
botEdge = 0;
figHeight = topEdge - botEdge;

% Place the ceiling labels
ceilPos1 = [leftEdge+(1/6)*figWidth-(1/2)*cWidth-.035, 1-cHeight, cWidth, cHeight];
ceilPos2 = [leftEdge+(3/6)*figWidth-(1/2)*cWidth-.035, 1-cHeight, cWidth, cHeight];
ceilPos3 = [leftEdge+(5/6)*figWidth-(1/2)*cWidth-.035, 1-cHeight, cWidth, cHeight];

p1 = annotation('textbox', 'String', 'Temperature Anomaly (\circC)', 'Fontsize', 18, ...
                'Position', ceilPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
p2 = annotation('textbox', 'String', '2\sigma Posterior Uncertainty', 'Fontsize', 18, ...
                'Position', ceilPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
p3 = annotation('textbox', 'String', '2\sigma Model Uncertainty', 'Fontsize', 18, ...
                'Position', ceilPos3, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );

% Place the left side labels
leftPos1 = [0, (3/4)*topEdge-(1/2)*lHeight, lWidth, lHeight];
leftPos2 = [0, (1/4)*topEdge-(1/2)*lHeight, lWidth, lHeight];

t1 = annotation('textbox', 'String', '1258', 'Fontsize', 18, ...
                'Position', leftPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
t2 = annotation('textbox', 'String', '1601', 'Fontsize', 18, ...
                'Position', leftPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );

% Subplot grid buffers
horizBuffer = 0.01;
vertBuffer = 0.02;

% Axes size
nRow = 2;
nCol = 3;
axWidth = (figWidth - (nCol+1)*horizBuffer) / nCol;
axHeight = (figHeight - (nRow+1)*vertBuffer) / nRow;

% Subplot axes
subAx = cell(nRow,nCol);
for row = 1:nRow
    axpos = [NaN, topEdge-row*(axHeight+vertBuffer), axWidth, axHeight];
    for col = 1:nCol
        axpos(1) = leftEdge + horizBuffer + (col-1)*(horizBuffer+axWidth);
        subAx{row,col} = axes( 'Position', axpos );
        xticks( subAx{row, col}, [] );
        yticks( subAx{row,col}, [] );
    end
end

% Do each plot
for row = 1:2
    for col = 1:3
        axes(subAx{row,col});
        m_proj('stereo','lat',90, 'lon', -30,'rad',60);
        map = maps{row,col};
        m_contourf([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
        m_coast;
        
        % Add the NTREND sites
        hold on
        for k = 1:numel(sites{row})
            s = sites{row}(k);
            switch types(s)
                case "RW"
                    mark = 'o';
                case "MXD"
                    mark = 's';
                case "MIX"
                    mark = 'v';
            end
            m_scatter( ntrend.coord(s,2), ntrend.coord(s,1), 25, 'k', mark, 'MarkerFaceColor', 'w');
        end
        m_grid('xtick', [], 'ytick', []);
        
        % Colorbar
        colorbar;
    end
end

% Colormaps
map = cbrew('redblue', 20, true);
scaleColorMap(map, 0, [subAx{1:2}], [-2.5 .5]);
scaleColorMap(map, 0, [subAx{3:4}]);
scaleColorMap(map, 0, [subAx{5:6}]);

% Export to .eps
name = 'figure10.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end          