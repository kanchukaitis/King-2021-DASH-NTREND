function[p] = patchInterval( x, center, upper, lower, color, varargin )
%% Creates a confidence interval patch
%
% p = patchInterval( x, center, bound )
%
% p = patchInterval( x, center, upper, lower )
%
% p = patchInterval( x, center, upper, lower, color, patchArgs )
%
% ----- Inputs -----
%
% x: The x values for the plot
%
% center: The center of the patch
%
% bound: The +/- values off the center
%
% upper: The + values off the center
%
% lower: The - values off the center
%
% color: The color. RGB triplet or color string
%
% patchArgs: Additional arguments to patch
%
% ----- Outputs -----
%
% p: patch handle

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get missing or empty inputs
if ~exist('lower','var') || isempty(lower)
    lower = upper;
end
if ~exist('color','var') || isempty(color)
    color = [0.5 0.5 0.5];
end
if isempty(varargin)
    varargin = {'FaceAlpha', .8, 'Linestyle', 'none'};
end

% Convert all to column
x = x(:);
center = center(:);
upper = upper(:);
lower = lower(:);

% Do the patch
p = patch( [x; flipud(x)], [center+upper; flipud(center-lower)], color, varargin{:} );

end