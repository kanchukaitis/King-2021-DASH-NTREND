function[] = figure5
%% Plots the spatial skill of the ensemble-mean reconstruction

% Load the skill metrics and NTREND metadata
skill = load('ensemble-spatial-skill.mat');
ntrend = gridfile('ntrend.grid');
ntrend = ntrend.metadata;
nSite = size(ntrend.coord,1);

% Reduce ntrend types ot RW, MXD, or mixed
type = ntrend.attributes.type;
type(~ismember(type, ["RW", "MXD"])) = "MIX";

% New figure
figPos = [123 33 761 603];
figure('position', figPos);

% Subplot grid buffers
horizBuffer = 0.01;
vertBuffer = 0.01;

% Get the edges of the subplot grid
leftEdge = 0 + horizBuffer;
rightEdge = 1-horizBuffer;
figWidth = rightEdge - leftEdge;

topEdge = 1 - vertBuffer;
botEdge = 0;
figHeight = topEdge - botEdge;

% Axes size
nRow = 2;
nCol = 2;
axWidth = (figWidth - (nCol+1)*horizBuffer) / nCol;
axHeight = (figHeight - (nRow+1)*vertBuffer) / nRow;

% Subplot axes
subAx = cell(nRow, nCol);
for row = 1:nRow
    axpos = [NaN, topEdge-row*(axHeight+vertBuffer), axWidth, axHeight];
    for col = 1:nCol
        axpos(1) = leftEdge + horizBuffer + (col-1)*(horizBuffer+axWidth);
        subAx{row,col} = axes( 'Position', axpos );
        xticks( subAx{row, col}, [] );
        yticks( subAx{row,col}, [] );
    end
end

% Cycle through skill maps
meta = skill.meta;
metrics = ["rho", "ratio", "rmse", "bias"];
names = {'Correlation','\sigma Ratio','RMSE (\circC)','Mean Bias (\circC)'};
ticks = {0:.25:.75, 0:.25:1.25, 0:.2:1.2, -.6:.3:.6};
for m = 1:numel(metrics)
    axes(subAx{m});
    map = skill.(metrics(m));
    
    % Plot the map
    m_proj('stereo','lon', -30, 'lat', 90, 'radius', 60 );
    m_contourf( [meta.lon;meta.lon(1)], meta.lat, [map, map(:,1)] );
    m_coast;
    
    % Plot the NTREND sites
    hold on
    for s = 1:nSite
        switch type(s)
            case "RW"
                mark = 'o';
            case "MXD"
                mark = 's';
            case "MIX"
                mark = 'v';
        end
        m_scatter( ntrend.coord(s,2), ntrend.coord(s,1), 25, 'k', mark, 'MarkerFaceColor', 'w');
    end    
    m_grid( 'xtick', [], 'ytick', [] );
    
    % Label the plot
    xlim = double( get(gca,'xlim') );
    ylim = double( get(gca,'ylim') );
    text( xlim(1), ylim(2), names{m}, 'FontSize', 16, 'FontWeight', 'bold' );
    
    % Apply colormaps
    if strcmp(metrics{m},'rho')
        scaleColorMap( cbrew('redblue',20,true), 0, gca, [-.08 .8] );
    elseif strcmp(metrics{m},'rmse')
        scaleColorMap( cbrew('redblue',20), 0, gca );
    elseif strcmpi(metrics{m}, 'bias')
        scaleColorMap( cbrew('redblue',20,true), 0, gca, [-.6 .6] );
    elseif strcmpi(metrics{m}, 'ratio')
        scaleColorMap( cbrew('redblue',20,true), 1, gca, [.1 1.27] );
    end
    colorbar('Ticks', ticks{m});
end

% Save
name = 'figure5.eps';
print(name, '-depsc', '-painters');
fixEPScontours(name);

end
