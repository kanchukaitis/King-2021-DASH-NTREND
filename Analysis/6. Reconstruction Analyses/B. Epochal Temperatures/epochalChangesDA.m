function[] = epochalChangesDA(name, mcaYears, liaYears)
%% Computes MCA-LIA temperature anomalies for the DA reconstructions

% Load the spatial reconstruction and get the ensemble metadata
recon = load(sprintf('%s-reconstruction.mat', name));
ens = ensemble(sprintf('%s.ens', name));
ensMeta = ens.metadata;

% Get the mca and lia periods
mca = ismember(recon.years, mcaYears);
lia = ismember(recon.years, liaYears);

% Load the data for the two periods
[mca, meta] = ensMeta.regrid(recon.out.Amean(:,mca), 'T', ["lat", "lon"]);
lia = ensMeta.regrid(recon.out.Amean(:,lia), 'T', ["lat", "lon"]);

% Take the time means and get the difference
mca = mean(mca, 3);
lia = mean(lia, 3);
delta = mca - lia;

% Save
saveName = sprintf('MCA-LIA-%s.mat', name);
save(saveName, 'delta', 'mcaYears', 'liaYears', 'meta');

end