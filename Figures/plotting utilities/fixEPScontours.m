function[] = fixEPScontours(name)
%% Fixes a problem with contour shading when exporting Matlab figures to eps

% Read the EPS file
text = fileread(name);

% Find the contour filling string
badSetting = '/f/fill ld';
len = numel(badSetting);
loc = strfind(text, badSetting);

% Split the text around the bad setting
head = text(1:loc-1);
tail = text(loc+len:end);

% Replace bad setting
goodSetting = '/f{GS 1 LW S GR fill}bd';
text = [head, goodSetting, tail];

% Rewrite file
delete(name);
file = fopen(name, 'w');
fprintf(file, '%s', text);
fclose(file);

end