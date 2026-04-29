function[] = epochalChangesEnsemble(mcaYears, liaYears)
%% Calculate MCA-LIA temperature anomalies for the DA model ensemble mean reconstruction

% Load the reconstruction
recon = load('ensemble-reconstruction.mat');

% Get the mca and lia periods
mca = ismember(recon.years, mcaYears);
lia = ismember(recon.years, liaYears);

% Load the data for the two periods
mca = recon.T(:,:,mca);
lia = recon.T(:,:,lia);
meta = recon.Tmeta;

% Take time means and get the difference
mca = mean(mca, 3);
lia = mean(lia, 3);
delta = mca - lia;

% Save
saveName = 'MCA-LIA-ensemble.mat';
save(saveName, 'delta', 'mcaYears', 'liaYears', 'meta');

end
