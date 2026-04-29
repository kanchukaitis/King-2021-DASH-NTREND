function[] = figure9
%% Plots the volcanic composite anomalies for external CFRs and the DA
% model ensemble mean reconstruction

% Create a full screen figure
figPos = [168 0 497 634];
fig = figure('position', figPos);

% Shared colorbar
a = axes('Position', [0 0 0 0]);
c = colorbar('Ticks', -1.5:.3:.9);
c.Label.String = 'Temperature Anomaly (\circC)';
fig.Children(1).Position = [.81 .02 .035 .91];
fig.Children(1).FontSize = 14;

% Get the edges of the workspace
cWidth = .3;
cHeight = .05;

leftEdge = 0.18;
rightEdge = 0.81;
figWidth = rightEdge-leftEdge;

topEdge = 1 - cHeight;
botEdge = 0;
figHeight = topEdge - botEdge;

% Place the ceiling labels
ceilPos1 = [leftEdge+(1/4)*figWidth-(1/2)*cWidth, 1-cHeight, cWidth, cHeight];
ceilPos2 = [leftEdge+(3/4)*figWidth-(1/2)*cWidth, 1-cHeight, cWidth, cHeight];

p1 = annotation('textbox', 'String', 'Year 0', 'Fontsize', 14, ...
                'Position', ceilPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Fontweight','bold' );
p2 = annotation('textbox', 'String', 'Year 1', 'Fontsize', 14, ...
                'Position', ceilPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Fontweight','bold' );

% Subplot grid buffers
horizBuffer = 0.01;
vertBuffer = 0.01;

% Axes size
nRow = 6;
nCol = 2;
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
cfrNames = ["ensemble", "ntrend", "guillet", "zhu", "lmr21", "neukomda"];
labels = ["NTREND DA", "NTREND PPR", "Guillet 2017", "Zhu 2020", "LMR 2.1", "Neukom DA"];
m = 1;
for row = 1:6
    cfr = load(sprintf('volcanic-composite-%s.mat', cfrNames(m)));
    meta = cfr.meta;
    for col = 1:2
        map = cfr.volc(:,:,col);
        
        % Plot the map
        axes( subAx{row,col} );
        m_proj('stereo', 'lon', -30, 'lat', 90, 'rad', 60);
        if m==2
            m_pcolor([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
        else
            m_contourf([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
        end
        m_coast;
        m_grid('xtick', [], 'ytick', []);
        
        % Label each row
        if col==1
            xlim = double( get(gca,'xlim') );
            ylim = double( get(gca,'ylim') );
            text( xlim(1)-.2, mean(ylim), labels(m), 'FontSize', 12, ...
                'FontWeight', 'bold', 'HorizontalAlignment', 'right' );
        end
    end
    m = m+1;
end

% Do the colormap
ax = [a, subAx{:}];
scaleColorMap(cbrew('redblue',20,true),0,ax,[-1.5 1.05]);

% Export to eps
name = 'figure9.eps';
print(name, '-depsc', '-painters');
fixEPScontours(name);

end