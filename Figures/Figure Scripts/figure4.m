function[] = figure4

% Load the time series data
data = load('time-series.mat');
ppr = data.ts.ppr;
da = data.ts.da;
be = data.ts.be;

% Set years for plots and anomalies
anomalyYears = 1951:1980;
allYears = 750:2011;

% Take the anomaly of all time series
anom = ismember(ppr.years, anomalyYears);
ppr.ts = ppr.ts - mean(ppr.ts(anom));
anom = ismember(be.years, anomalyYears);
be.ts = be.ts - mean(be.ts(anom));
anom = ismember(da.years, anomalyYears);
da.ts = da.ts - mean(da.ts(anom));

% Initialize the figure and axes positions
figure('units','inches','Position', [0 0 6.5 6.5]);
pos1 = [.07, .75, .93, .25];
pos2 = [.07 .4 .93 .3];
pos3 = [.07, .1, .93, .3];

% Plot modern
axes('Position', pos1);
x = 1850:1988;
use = ismember(da.years, x);

pk = patchInterval(x, da.ts(use), 2*da.Uposterior(use), [], [.75 .75 .75]);
hold on
pm = patchInterval(x, da.ts(use), 2*da.Umodel(use), [], [.35 .35 .35]);
pd = plot(x, da.ts(use), 'linewidth', 1);
pp = plot(ppr.years, ppr.ts, 'linewidth', 1);
pb = plot(be.years, be.ts, 'linewidth', 1);

set(gca,'fontsize',10,'xlim',[1850 2019],'ylim',[-1.763 1.2366]);
legend([pb pk pp pm pd], 'Berkeley Earth', '2\sigma (Posterior ensemble)', ...
       'NTREND 2017', '2\sigma (Model prior)', 'Ensemble Mean', ...
       'Location','southwest','fontsize',10,'NumColumns',3,'Location','southeast');
legend('boxoff');

% Full period time series
axes('Position', pos2);
k = 3;
x = 751:1988;

movDA = movmean(da.ts, k, 'Endpoints', 'fill');
movPPR = movmean(ppr.ts, k, 'Endpoints', 'fill');
movBE = movmean(be.ts, k, 'Endpoints', 'fill');

patchDA = movmean(da.ts, k);
use = ismember(da.years, x);
pk = patchInterval(x, patchDA(use), 2*da.Uposterior(use), [], [.75 .75 .75] );
hold on
pm = patchInterval(x, patchDA(use), 2*da.Umodel(use), [], [.4 .4 .4]);

pd = plot(da.years(use), movDA(use), 'linewidth', 1);
pp = plot(ppr.years, movPPR, 'linewidth', 1);
pb = plot(be.years, movBE, 'linewidth', 1);

set(gca,'fontsize',10,'xlim',[750 2019],'ylim',[-1.763 1.2366],'xtick',[]);
t = text(670, -.5, 'Temperature Anomaly (\circC)', 'FontSize',12,'Rotation',90);

% Running standard deviation
axes('Position', pos3);

plot(da.years, da.std, 'linewidth', 1);
hold on
plot(ppr.years, ppr.std, 'linewidth', 1);

set(gca,'xlim',[750 1988],'fontsize',10)
xlabel('Year (CE)','Fontsize',12);
ylabel( 'Running \sigma (\circC)','Fontsize',12 );
a3.Box = 'off';

% Export to EPS
name = 'figure4.eps';
print(name, '-depsc', '-painters');
fixEPScontours(name);

end



