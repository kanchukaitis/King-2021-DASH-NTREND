function[] = supfigure6
%% Plots DA vs PPR skill for an MPI target

% Set the target and prior
targetName = 'mpi';
priorName = 'cesm';

% Load the skill data
da = load(sprintf('%s_target-%s_prior-noisy-attrition-skill.mat', targetName, priorName));
ppr = load(sprintf('ppr-%s_target-noisy-attrition-skill.mat', targetName));
delta = load(sprintf('DAvsPPR-%s_target-%s_prior.mat', targetName, priorName));

% Get NTREND metadata
ntrend = gridfile('ntrend.grid').metadata;
types = ntrend.attributes.type;
types(~ismember(types, ["RW","MXD"])) = "MIX";

% Create a full screen figure
figPos = [80 33 665 603];
fig = figure('position', figPos);

% Heights and widths
tHeight = 0;
lWidth = 0.09;
lHeight = .04;
cWidth = .3;
cHeight = .1;

leftEdge = lWidth;
rightEdge = 1;
figWidth = rightEdge - leftEdge;

topEdge = 1 - tHeight - cHeight;
botEdge = 0;
figHeight = topEdge - botEdge;

% Place the ceiling labels
ceilPos1 = [leftEdge+(1/6)*figWidth-(1/2)*cWidth-.035, 1-tHeight-cHeight, cWidth, cHeight];
ceilPos2 = [leftEdge+(3/6)*figWidth-(1/2)*cWidth-.035, 1-tHeight-cHeight, cWidth, cHeight];
ceilPos3 = [leftEdge+(5/6)*figWidth-(1/2)*cWidth-.035, 1-tHeight-cHeight, cWidth, cHeight];

p1 = annotation('textbox', 'String', 'DA', 'Fontsize', 18, ...
                'Position', ceilPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
p2 = annotation('textbox', 'String', 'PPR', 'Fontsize', 18, ...
                'Position', ceilPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
p3 = annotation('textbox', 'String', '\Delta: DA - PPR ', 'Fontsize', 18, ...
                'Position', ceilPos3, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );

% Subplot grid buffers
horizBuffer = 0.01;
vertBuffer = 0.01;

% Axes size
nRow = 4;
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

% Collect map metadata, plot labels, and colorbar limits
metas = {da.spatial.meta, ppr.spatial.meta, delta.meta};
rowLabels = ["Correlation", "RMSE", "\sigma Ratio", "Mean Bias (\circ C)"];
limits1 = {[-.0833, .8333], [0 2.5], [0 1.5],  [-1.5 1.05]};
limits2 = {[-.08 .4], [-.6667 .0667], [-.8333 0], [-1 .6]};
ticks1 = {0:.25:.75, 0:.5:2.5, 0:.5:1.5, -1.35:.45:.9};
ticks2 = {-.08:.08:.4, -.6:.2:0, -.75:.25:0, -2:.5:.5};

% Get the maps for each metric
metrics = ["rho","rmse","ratio","bias"];
for row = 1:numel(metrics)
    metric = metrics(row);
    damap = median(da.spatial.(metric), 3);
    pprmap = ppr.spatial.(metric);
    deltamap = delta.delta.(metric);
    
    % Cycle through columns
    maps = {damap, pprmap, deltamap};
    for col = 1:3
        
        % Place row labels on the first column
        if col==1
            pos = subAx{row, col}.Position;
            a = axes('Position', pos);
            str = strcat( newline, rowLabels(row));
            if row==4
                str = [' ', str];
            end
            ylabel(str, 'Fontsize',16);
            a.XAxis.Visible = 'off';
            a.YAxis.Visible = 'off';
            a.YAxis.Label.Visible = 'on';
        end
        
        % Plot the map
        axes(subAx{row, col});
        map = maps{col};
        meta = metas{col};
        m_proj('stereo', 'lon', -30, 'lat', 90, 'radius', 60);
        m_contourf( [meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)] );
        m_coast;
        
        % Plot the NTREND sites
        hold on
        for s = 1:size(ntrend.coord)
            switch types(s)
                case "RW"
                    mark = 'o';
                case "MXD"
                    mark = 's';
                case "MIX"
                    mark = 'v';
            end
            m_scatter( ntrend.coord(s,2), ntrend.coord(s,1), 15, 'k', mark, 'MarkerFaceColor', 'w');
        end
        m_grid('xtick', [], 'ytick', []);    
        
        % Colorbar
        if ismember(col, [1 2])
            colorbar('Ticks', ticks1{row});
        else
            colorbar('Ticks', ticks2{row});
        end
    end
    
    % Colormaps
    ax = [subAx{row,:}];
    map = cbrew('redblue',20, true);
    map2 = map;
    center = 0;
    
    if row == 3
        center = 1;
    end
    if row == 2
        map = flipud(map);
        map2 = flipud(map2);
    end
    
    scaleColorMap(map, center, ax(1:2), limits1{row});
    scaleColorMap(map2, 0, ax(3), limits2{row});
end

% Export to .eps
name = 'supfigure6.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end

        