function[T, A, Ameta] = matchGrids(T, Tmeta, A, Ameta)
%% Matches two spatial grids to the same resolution. Uses the lowest resolution
% across the two grids

% Check the number of spatial gridpoints in the two grids
Tpoints = prod(size(T, [1 2]));
Apoints = prod(size(A, [1 2]));

% If A has higher resolution, downgrid
if Apoints > Tpoints
    A = downgrid(A, Ameta, T, Tmeta);
    Ameta = Tmeta;
    
% If T has higher resolution, downgrid
elseif Tpoints > Apoints
    T = downgrid(T, Tmeta, A, Ameta);
end

end

function[Aq] = downgrid(A, Ameta, T, Tmeta)

% Start by wrapping the longitude points of the big grid
Ameta.lon = cat(1, Ameta.lon(end)-360, Ameta.lon, Ameta.lon(1)+360);
A = cat(2, A(:,end,:), A, A(:,1,:));

% Preallocate and query via 2D interpolation
Aq = NaN(size(T));
for k = 1:size(T,3)
    Aq(:,:,k) = interp2( Ameta.lon', Ameta.lat, A(:,:,k), Tmeta.lon', Tmeta.lat);
end

end