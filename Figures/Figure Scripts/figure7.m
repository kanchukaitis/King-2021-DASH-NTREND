function[] = figure7
%% Plots epochal temperature changes for the CFRs and DA model ensemble mean reconstruction

% Create a new figure
figPos = [229 36 580 600];
fig = figure('position', figPos);

% Shared colorbar
a = axes('Position', [0 0 0 0]);
c = colorbar('Ticks', -.6:.3:1.5);
c.Label.String = 'Temperature Anomaly (\circC)';
fig.Children(1).Position = [.855 .02 .03 .95];
fig.Children(1).FontSize = 14;

% Get the edges of the workspace
leftEdge = 0;
rightEdge = 0.85;
figWidth = rightEdge-leftEdge;

topEdge = 1;
botEdge = 0;
figHeight = topEdge - botEdge;

% Subplot grid buffers
horizBuffer = 0.01;
vertBuffer = 0.01;

% Axes size
nRow = 3;
nCol = 2;
axWidth = (figWidth - (nCol+1)*horizBuffer) / nCol;
axHeight = (figHeight - (nRow+1)*vertBuffer) / nRow;

% Subplot axes
subAx = cell(nRow,nCol);
for row = 1:nRow
    axpos = [NaN, topEdge-row*(axHeight+vertBuffer), axWidth, axHeight];
    for col = 1:nCol
        if row==3 && col==1
            axpos(1) = mean([leftEdge,rightEdge])-(axWidth/2);
        elseif row==3 && col==2
            break;
        else
            axpos(1) = leftEdge + horizBuffer + (col-1)*(horizBuffer+axWidth);
        end
        subAx{row,col} = axes( 'Position', axpos );
        xticks( subAx{row, col}, [] );
        yticks( subAx{row,col}, [] );
    end
end

% Load the map for each CFR
cfrNames = ["ensemble", "ntrend", "zhu", "neukomda", "lmr21"];
labels = ["NTREND DA", "NTREND PPR", "Zhu 2020", "Neukom DA", "LMR 2.1"];
m = 1;
for row = 1:3
    for col = 1:2
        if row==3 && col==2
            break;
        end
        cfr = load(sprintf('MCA-LIA-%s.mat', cfrNames(m)));
        map = cfr.delta;
        meta = cfr.meta;
        
        % Plot
        axes(subAx{row,col});
        m_proj('stereo', 'lon', -30, 'lat', 90, 'rad', 60);
        if m==2
            m_pcolor([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
        else
            m_contourf([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
        end
        m_coast;
        m_grid('xtick', [], 'ytick', []);

        % Label the plot
        xlim = double( get(gca,'xlim') );
        ylim = double( get(gca,'ylim') );
        text(xlim(1), ylim(2), labels(m), 'FontSize', 16, 'FontWeight', 'bold' );
        m = m+1;
    end
end

% Do the colormap
ax = [a, subAx{:}];
scaleColorMap(cbrew('redblue', 20, true), 0, ax, [-.6 1.5]);

% Export to eps
name = 'figure7.eps';
print(name, '-depsc', '-painters');
fixEPScontours(name);

end