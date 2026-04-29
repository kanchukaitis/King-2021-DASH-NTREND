function[slope, intercept, R] = regression(X, Y)
%% Does a regression

b = X\Y;
slope = b(2);
intercept = b(1);
predicted = X*b;
residuals = Y - predicted;
R = nanvar(residuals);

end