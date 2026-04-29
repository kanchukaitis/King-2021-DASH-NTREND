function[] = supfigure5
%% Plots the time series for the pseudo-proxy experiments with an MPI target

% Initialize the figure
figure('position', [1 1 1280 643]);

% Load the time series data
ts = load('time-series-mpi_target.mat');
da = ts.ts.da;
ppr = ts.ts.ppr;
target = ts.ts.target;

% Plot the time series
subplot(2,1,1);
pd = plot(ts.years, movmean(da.ts,3));
hold on
pp = plot(ts.years, movmean(ppr.ts,3));
pt = plot(ts.years, movmean(target.ts,3));
set(gca,'xlim',[850 1988], 'fontsize', 16, 'ylim', [-2.5 1.4]);
ylabel('Temperature Anomaly (\circC)');
legend([pd, pp, pt], 'DA', 'PPR', 'MPI Target', 'Location', 'northeast', 'fontsize', 12, 'NumColumns', 3);
legend('boxoff');

% Plot the running standard deviation
subplot(2,1,2);
pd = plot(ts.years, movmean(da.std,3));
hold on
pp = plot(ts.years, movmean(ppr.std, 3));
pt = plot(ts.years, movmean(target.std,3));
set(gca, 'xlim', [850 1988], 'fontsize', 16);
xlabel('Year (CE)');
ylabel('Running \sigma (\circC)');
legend([pd, pp, pt], 'DA', 'PPR', 'MPI Target', 'Location', 'northeast', 'fontsize', 12, 'NumColumns', 3);
legend('boxoff');

% Export to .eps
name = 'supfigure5.eps';
print(name,'-depsc','-painters');
fixEPScontours(name);
end