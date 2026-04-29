function[] = figure8
%% Plots the volcanic composite anomalies for the DA reconstructions

% Get NTREND metadata
ntrend = gridfile('ntrend.grid').metadata;
types = ntrend.attributes.type;
types(~ismember(types, ["RW","MXD"])) = "MIX";

% Create a full screen figure
figPos = [9 2 713 634];
fig = figure('position', figPos);

% Shared colorbar
a = axes('Position', [0 0 0 0]);
c = colorbar('Ticks', -1.5:.3:.9);
c.Label.String = 'Temperature Anomaly (\circC)';
fig.Children(1).Position = [.885 .04 .02 .92];
fig.Children(1).FontSize = 14;

% Get the edges of the workspace
leftEdge = 0;
rightEdge = 0.91;
figWidth = rightEdge-leftEdge;

topEdge = 1;
botEdge = 0;
figHeight = topEdge - botEdge;

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
        if ~(row==4 && ismember(col, [1 3]))
            axpos(1) = leftEdge + horizBuffer + (col-1)*(horizBuffer+axWidth);
            subAx{row,col} = axes( 'Position', axpos );
            xticks( subAx{row, col}, [] );
            yticks( subAx{row,col}, [] );
        end
    end
end

% Do each plot
modelNames = ["bcc","ccsm4","cesm","csiro","fgoals","hadcm3","ipsl","miroc","mpi","mri"];
labels = ["BCC", "CCSM4", "CESM", "CSIRO", "F-GOALS", "HadCM3", "IPSL", "MIROC", "MPI", "MRI"];
m = 1;
for row = 1:4
    for col = 1:3
        if ~(row==4 && ismember(col, [1 3]))
            da = load(sprintf('volcanic-composite-%s.mat', modelNames(m)));
            map = da.volc(:,:,1);
            meta = da.meta;
            
            % Plot
            axes(subAx{row,col});
            m_proj('stereo', 'lon', -30, 'lat', 90, 'rad', 60);
            m_contourf([meta.lon; meta.lon(1)], meta.lat, [map, map(:,1)]);
            m_coast;
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

            % Label the plot
            xlim = double( get(gca,'xlim') );
            ylim = double( get(gca,'ylim') );
            text(xlim(1), ylim(2), labels(m), 'FontSize', 16, 'FontWeight', 'bold' );
            m = m+1;
        end
    end
end

% Colormap
ax = [a, subAx{:}];
scaleColorMap(cbrew('redblue',20,true), 0, ax, [-1.5 1.05] );

% Export to .eps
name = 'figure8.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end