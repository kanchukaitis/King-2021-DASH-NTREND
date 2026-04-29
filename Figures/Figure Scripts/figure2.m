function[] = figure2
%% Plots the spatial correlation of the pseudo-proxy experiments

% Make the plot
[ax, c] = plotPseudoSpatialSkill('rho');
scaleColorMap( cbrew('redblue',20,true), 0, ax, [-.4 1] );
c.Label.String = 'Correlation Coefficient';

% Export to .eps
name = 'figure2.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end