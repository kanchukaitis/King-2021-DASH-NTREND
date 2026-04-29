function[] = supfigure2
%% Plots the spatial standard deviation ratio for the pseudo-proxies

% Make the plot
[ax, c] = plotPseudoSpatialSkill('ratio');
scaleColorMap( cbrew('redblue',20,true), 1, ax, [0 1.6] );
c.Label.String = '\sigma Ratio';

% Export to .eps
name = 'supfigure2.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end