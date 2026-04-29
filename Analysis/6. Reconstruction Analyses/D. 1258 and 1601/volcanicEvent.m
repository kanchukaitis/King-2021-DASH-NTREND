function[] = volcanicEvent(volcYear)

% Load the ensemble reconstruction
da = load('ensemble-reconstruction.mat');
years = da.years;
meta = da.recon.spatial.meta;
anomalyYears = da.anomalyYears;

% Get the temperature anomaly and uncertainties from the year
use = years==volcYear;
T = da.recon.spatial.T(:,:,use);
Uposterior = da.recon.spatial.Uposterior(:,:,use);
Umodel = da.recon.spatial.Umodel(:,:,use);

% Save
saveName = sprintf('%.f-event.mat', volcYear);
save(saveName, 'T', 'Uposterior', 'Umodel', 'meta', 'volcYear', 'anomalyYears');

end