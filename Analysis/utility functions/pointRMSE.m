function[rmse] = pointRMSE( T, S, varargin)
%% Point by point RMSE
% rmse = pointRMSE( T, S, 'dim', d, 'meanArgs', {meanArg} )

% Parse the inputs
[d, meanArg] = dash.parseInputs( varargin, {'dim','meanArgs'}, {1,{}}, 2 );

% Check that T and S are the same size
if ~isequal( size(T), size(S) )
    error('The size of T and S must be the same.');
end

% Get the rmse
rmse = sqrt( mean( (T-S).^2, d, meanArg{:} ) );
end