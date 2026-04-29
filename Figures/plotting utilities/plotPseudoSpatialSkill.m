function[ax, c] = plotPseudoSpatialSkill2(metricName)
%% Plots skill maps for pseudoproxy DA tests
%
% ax: Colormap axes
%
% c: colorbar object

% Preallocate the skill maps and metadata
map = cell(4,4);
meta = cell(4,4);

% Get the file settings
priors = ["mpi", "cesm"];
targets = ["mpi", "cesm"];
attrition = ["noAttrition", "attrition"];

% Collect skill metrics and map metadata
perfect = [1:4, 9:12];
noisy = [5:8, 13:16];
k = 1;
for p = 1:2
    for t = 1:2
        for a = 1:2
            skill = load(sprintf('%s_target-%s_prior-perfect-%s-skill.mat', targets(t), priors(p), attrition(a)));
            map{perfect(k)} = skill.spatial.(metricName);
            meta{perfect(k)} = skill.spatial.meta;
            
            skill = load(sprintf('%s_target-%s_prior-noisy-%s-skill.mat', targets(t), priors(p), attrition(a)));
            map{noisy(k)} = median(skill.spatial.(metricName), 3);
            meta{noisy(k)} = skill.spatial.meta;
            k=k+1;
        end
    end
end

% Create the figure
figPos = [1, 1, 6.7 3.2652];
fig = figure('units','inches','position', figPos);

% Shared colorbar
a = axes('Position', [0 0 0 0]);
c = colorbar;
fig.Children(1).Position = [.9022 .03 .015 .86];
fig.Children(1).FontSize = 10;

% Get the width and height of prior/target labels and network labels
tHeight = 0.04;
ptWidth = .18;
ptHeight = .04;
netWidth = .15;
netHeight = .04;

% Get the edges of the figure not covered by the labels
leftEdge = ptWidth;
rightEdge = .9022;
figWidth = rightEdge - leftEdge;

topEdge = 1 - tHeight - ptHeight - netHeight;
botEdge = 0;
figHeight = topEdge - botEdge;

% Place the target labels
tarPos1 = [0, (3/4)*topEdge-(1/2)*ptHeight, ptWidth, ptHeight];
tarPos2 = [0, (1/4)*topEdge-(1/2)*ptHeight, ptWidth, ptHeight];

t1 = annotation('textbox', 'String', 'MPI Target', 'Fontsize', 12, ...
                'Position', tarPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
t2 = annotation('textbox', 'String', 'CESM Target ', 'Fontsize', 12, ...
                'Position', tarPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
            
% Place the full / attrition labels
fullPos1 = [leftEdge-netWidth, (7/8)*topEdge-(1/2)*netHeight, netWidth, netHeight];
fullPos2 = [leftEdge-netWidth, (3/8)*topEdge-(1/2)*netHeight, netWidth, netHeight];
attPos1 = [leftEdge-netWidth, (5/8)*topEdge-(1/2)*netHeight, netWidth, netHeight];
attPos2 = [leftEdge-netWidth, (1/8)*topEdge-(1/2)*netHeight, netWidth, netHeight];

f1 = annotation('textbox', 'String', 'Full network', 'Fontsize', 10, ...
                'Position', fullPos1, 'Linestyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
f2 = annotation('textbox', 'String', 'Full network', 'Fontsize', 10, ...
                'Position', fullPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
a1 = annotation('textbox', 'String', 'Attrition', 'Fontsize', 10, ...
                'Position', attPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
a2 = annotation('textbox', 'String', 'Attrition', 'Fontsize', 10, ...
                'Position', attPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle' );
            
% Place the prior labels
priPos1 = [leftEdge+(1/4)*figWidth-(1/2)*ptWidth, 1-tHeight-ptHeight, ptWidth, ptHeight];
priPos2 = [leftEdge+(3/4)*figWidth-(1/2)*ptWidth, 1-tHeight-ptHeight, ptWidth, ptHeight];

p1 = annotation('textbox', 'String', 'MPI Prior', 'Fontsize', 12, ...
                'Position', priPos1, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
p2 = annotation('textbox', 'String', 'CESM Prior', 'Fontsize', 12, ...
                'Position', priPos2, 'LineStyle', 'none', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );

            
% Place the noisy / perfect labels
perPos1 = [leftEdge+(1/8)*figWidth-(1/2)*netWidth, 1-tHeight-ptHeight-netHeight, netWidth, netHeight];
perPos2 = [leftEdge+(5/8)*figWidth-(1/2)*netWidth, 1-tHeight-ptHeight-netHeight, netWidth, netHeight];
noisePos1 = [leftEdge+(3/8)*figWidth-(1/2)*netWidth, 1-tHeight-ptHeight-netHeight, netWidth, netHeight];
noisePos2 = [leftEdge+(7/8)*figWidth-(1/2)*netWidth, 1-tHeight-ptHeight-netHeight, netWidth, netHeight];

per1 = annotation('textbox', 'String', 'Perfect', 'Fontsize', 10, ...
                  'Position', perPos1, 'LineStyle', 'none', ...
                  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
per2 = annotation('textbox', 'String', 'Perfect', 'Fontsize', 10, ...
                  'Position', perPos2, 'LineStyle', 'none', ...
                  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
noise1 = annotation('textbox', 'String', 'Noisy', 'Fontsize', 10, ...
                  'Position', noisePos1, 'LineStyle', 'none', ...
                  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
noise2 = annotation('textbox', 'String', 'Noisy', 'Fontsize', 10, ...
                  'Position', noisePos2, 'LineStyle', 'none', ...
                  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' );
       
% Add target-prior pair lines
lhoriz = annotation('line', [leftEdge+.01 rightEdge-.01], [topEdge/2, topEdge/2], 'linewidth', 1.5 );
middle = mean([leftEdge, rightEdge]);
lvert = annotation('line', [middle middle], [topEdge-.03, .025], 'linewidth', 1.5 );

% Add subplot axes
horizBuffer = 0.01;
vertBuffer = 0.01;
axWidth = (figWidth - 5*horizBuffer) / 4;
axHeight = (figHeight - 5*vertBuffer) / 4;

subAx = cell(4,4);
for row = 1:4
    axpos = [NaN, topEdge-row*(axHeight+vertBuffer), axWidth, axHeight];
    for col = 1:4
        axpos(1) = leftEdge + horizBuffer + (col-1)*(horizBuffer+axWidth);
        subAx{row,col} = axes( 'Position', axpos );
        xticks( subAx{row, col}, [] );
        yticks( subAx{row,col}, [] );
    end
end

for row = 1:4
     for col = 1:4
        metric = map{row,col};
        Ameta = meta{row,col};
        axes( subAx{row, col} ); %#ok<LAXES>
        m_proj('robinson', 'lon', [0 360], 'lat', [-80 80]);
        m_contourf( Ameta.lon, Ameta.lat, metric );
        m_coast;
        hold on
        m_plot( [0 360], [30 30], 'k', 'linewidth', 1 );
        m_grid( 'xtick', [], 'ytick', [] );
    end
end

% Get the axes output
ax = [a, subAx{:}];

end