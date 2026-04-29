function[bias] = pointMeanBias(T, S, varargin)
%% Gets point by point bias in means
%
% bias = meanBias(T, S)
%
% bias = meanBias(..., 'dim', d )
%
% bias = pointMeanBias( ..., meanArgs, {args} )

% Parse inputs
[d, meanArg] = dash.parseInputs( varargin, {'dim','meanArgs'}, {1,{}}, 2 );

% Check that the sizes are the same except for dimension d
sizT = size(T);
sizS = size(S);
if sizT([1:d-1, d+1:end]) ~= sizS([1:d-1, d+1:end])
    error('S and T must have the same size (except in dimension over which bias is calculated).');
end

% Compute the bias
bias = mean(S,d,meanArg{:}) - mean(T,d,meanArg{:});
end