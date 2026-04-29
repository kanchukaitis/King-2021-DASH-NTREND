function[] = supfigure7
%% Plots the time series for the individual reconstructions

% Get the models to plot
modelNames = ["bcc","ccsm4","cesm","csiro","fgoals","hadcm3","ipsl","miroc","mpi","mri"];
labels = {"BCC", "CCSM4", "CESM", "CSIRO", "FGOALS", "HadCM3", "IPSL", "MIROC", "MPI", "MRI"}; %#ok<CLARRSTR>

% Create a new figure
figpos = [1 1 1280 643];
figure('Position', figpos);
hold on

% Apply a 31 year smooth
k = 31;

% Plot each reconstruction
for m = 1:numel(modelNames)
    recon = load(sprintf('%s-reconstruction.mat', modelNames(m)));
    plot(recon.years, movmean(recon.ts, k));
end

set(gca,'xlim', [750 1988], 'fontsize', 16);
xlabel('Year (CE)', 'Fontsize',18);
ylabel('Temperature Anomaly (\circC)', 'Fontsize', 18);
ll = legend(labels{:}, 'NumColumns', 3);
legend('boxoff')

% Add in sample depth
ntrend = gridfile('ntrend.grid');
X = ntrend.load;
N = sum(~isnan(X));

yyaxis right
ax = gca;
ax.YAxis(2).Color = [0 0 0];
plot(recon.years, N, 'k');
yl = ylabel(sprintf('Sample Depth'));
yl.Rotation = 270;
yl.Position(1) = 2075;

ll.String{end} = 'Sample Depth';
ll.Position = [0.14245      0.76179      0.32891      0.16407];

% Save
name = 'supfigure7.eps';
print(name, '-depsc','-painters');
fixEPScontours(name);

end
    
    