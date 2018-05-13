function F = eightPointAlgorithm(x1, y1, x2, y2)

% Construct the n × 9 matrix A
A = [x1.*x2, x1.*y2, x1, y1.*x2, y1.*y2, y1, x2, y2, ones(size(x1))];

% Find the SVD of A
[~,D,V] = svd(A);

% The entries of F are the components of the column of V corresponding to the smallest singular value.
[~,I] = min(max(D)); % smalles singular value 
F = reshape(V(:,I),[3,3]);

% Find the SVD of F
[Uf, Df, Vf] = svd(F);

% Set the smallest singular value in the diagonal matrix Df to zero in order to obtain the corrected matrix D'f
[~,I] = min(max(Df));
Df(I,I) = 0;

% Recompute F
F = Uf*Df*Vf';

end