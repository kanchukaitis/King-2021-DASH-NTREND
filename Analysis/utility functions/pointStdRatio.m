function[stdRatio] = pointStdRatio( T, S, varargin )

% Parse inputs
[d, weight, stdArg] = dash.parseInputs( varargin, {'dim','weight','stdArgs'}, {1,[],{}}, 2 );

% Check that the sizes are the same except for dimension d
sizT = size(T);
sizS = size(S);
if sizT([1:d-1, d+1:end]) ~= sizS([1:d-1, d+1:end])
    error('S and T must have the same size (except in dimension over which bias is calculated).');
end

% Get the standard deviation ratio
stdRatio = std(S,weight,d,stdArg{:}) ./ std(T, weight, d, stdArg{:});
end