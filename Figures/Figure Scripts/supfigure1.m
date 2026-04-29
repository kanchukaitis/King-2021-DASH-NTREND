function[] = supfigure1
%% Plots the spatial RMSE for the pseudo-proxy sensitivity tests

% Make the plot
[ax, c] = plotPseudoSpatialSkill('rmse');
scaleColorMap( cbrew('redblue',20), 0, ax, [0 2]  );
c.Label.String = 'RMSE';

% Export to .eps
name = 'supfigure1.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);

end