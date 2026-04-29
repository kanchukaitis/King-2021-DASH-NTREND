function[] = supfigure3
%% Plots the spatial mean bias for the pseudo-proxy assimilations

% Make the plot
[ax, c] = plotPseudoSpatialSkill('bias');
scaleColorMap( cbrew('redblue',20,true), 0, ax, [-1.5 2] );
c.Label.String = 'Mean Bias (\circC)';

% Export to .eps
name = 'supfigure3.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end