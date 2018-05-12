function F = normalizedEightPointAlgorithm(x1, y1, x2, y2)

% Normalization
[x1, y1, T1] = normalizeData(x1, y1);
[x2, y2, T2] = normalizeData(x2, y2);
% Eight Point Algorithm
F = eightPointAlgorithm(x1, y1, x2, y2);
% Denormalization
F = T2' * F * T1;

end