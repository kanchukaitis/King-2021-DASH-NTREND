function[D] = attrite(D, years)
%% Adds temporal attrition to pseudo-proxies

% Get the NTREND records and metadata
ntrend = gridfile('ntrend.grid');
records = ntrend.load;
ntrend = ntrend.metadata;

% Limit NTREND to the pseudo-proxy years
use = ismember(ntrend.time, years);
records = records(:, use);

% Match the NaN records
delete = isnan(records);
D(delete) = NaN;

end

