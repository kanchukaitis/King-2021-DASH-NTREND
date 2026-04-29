function[cmap] = cbrew( name, N, flip )
%% Creates high-resolution colormaps from colorbrewer color schemes
%
% cmap = cbrew( name, N )
% Return a colormap with N color points.
%
% cmap = cbrew( name, N, flip )
% Specify whether to invert a colormap. Default is false.
%
% cbrew( 'maps' )
% Return a list of supported colormaps
%
% cbrew( 'seq' )
% Return a list of sequential colormaps
%
% cbrew( 'div' )
% Return a list of diverging colormaps
%
% ----- Inputs -----
%
% name: The name of a colorbrewer colormap
%       'redblue': A red-blue diverging map
%       'brownblue': A brown-blue diverging map
%       'whitecoolwarm': 
%       'wyblue': A sequential map grading from a whitish-yellow to deep blue
%       'wyred': A sequential map from a whitish-yellow to deep red. 
%
% N: The number of color points to include in the map
%
% flip: A scalar boolean specifying whether to flip a colormap
%
% ----- Outputs -----
%
% cmap: A colormap

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get the supported maps and their status
maps = ["redblue";"brownblue";"whitecoolwarm";"wyblue";"wyred"];
seq =  [ false;       false;       true;        true;    true  ];
div =  [ true;        true;       false;        false;   false ];

% If only one input, just return a list of maps
if nargin == 1
    if strcmp(name, "maps")
        cmap = maps;
    elseif strcmp(name, "seq")
        cmap = maps(seq);
    elseif strcmp(name, "div")
        cmap = maps(div);
    elseif ismember( name, maps )
        error('You need to specify how many color points in the map.');
    else
        error('Unrecognized name');
    end
    
    % Just return the list, don't bother with calculations
    return;
end

% Otherwise, load the appropriate colormap
if strcmp( name, "redblue" )
    map = redblue;
elseif strcmp( name, "brownblue" )
    map = brownblue;
elseif strcmp(name, "whitecoolwarm")
    map = whitecoolwarm;
elseif strcmp(name, "wyblue")
    map = wyblue;
elseif strcmp(name, "wyred")
    map = wyred;
else
    error('Unrecognized map');
end

% Choose whether to flip the colormap
if nargin > 2
    if ~isscalar(flip) || ~islogical(flip)
        error('flip must be a scalar logical.');
    elseif flip
        map = flipud(map);
    end
end 

% Get an index mapping the old colorspace to the new colorspace
nColor = size(map,1);
oldPoints = (1:nColor)';
newPoints = linspace( 1, nColor, N )';

% Preallocate the new colormap
cmap = NaN( N, 3 );

% Do linear interpolation to get the intermediate colors for each RGB channel
for c = 1:3    
    cmap(:,c) = interp1( oldPoints, map(:,c), newPoints ); 
end

end