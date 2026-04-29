function[rho] = pointCorr( T, S, varargin )

% Parse Inputs
[d, nanflag] = dash.parseInputs( varargin, {'dim','nanflag'}, {1,'includenan'}, 2 );

% Check the sizes are the same
if ~isequal( size(T), size(S) )
    error('T and S must have the same size.');
end

% Get a dimensional ordering that places the correlation dimension as the
% first dimension.
dimOrder = 1:max(ndims(T),d);
dimOrder(1) = d;
dimOrder(d) = 1;

% Permute to first
T = permute(T, dimOrder);
S = permute(S, dimOrder);

% Use a pairwise setup
nanval = isnan(T) | isnan(S);
T(nanval) = NaN;
S(nanval) = NaN;

% Remove means
T = T - mean(T,1,nanflag);
S = S - mean(S,1,nanflag);

% Get standard deviation
Tstd = std(T,0,1,nanflag);
Sstd = std(S,0,1,nanflag);

% Compute correlation
unbias = 1 / (size(T,1)-1);
rho = unbias * nansum(T.*S, 1) ./ (Tstd.*Sstd);
rho(isinf(rho)) = NaN;

% Unpermute
rho = permute( rho, dimOrder );

end