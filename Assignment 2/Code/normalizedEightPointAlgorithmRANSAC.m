function F = normalizedEightPointAlgorithmRANSAC(x1, y1, x2, y2, parameters)
if parameters.threshold > 0  threshold = parameters.threshold; else threshold = 1.0e-04; end

% Normalization
[x1, y1, T1] = normalizeData(x1, y1);
[x2, y2, T2] = normalizeData(x2, y2);

% RANSAC
num_points = size(x1, 1);
final_inliers = [];
for i = 1:100
    % Get Fundamental Matrix of 8 random points
    random_points = randi(num_points, [8,1]);
    rx1 = x1(random_points);
    ry1 = y1(random_points);
    rx2 = x2(random_points);
    ry2 = y2(random_points);
    Fp = eightPointAlgorithm(rx1, ry1, rx2, ry2);


    % Get inliers of F using Sampson distance
    inliers = [];
    for j = 1:length(x1)
        p1 = [x1(j); y1(j); 1];
        p2 = [x2(j); y2(j); 1];
        Fp1 = Fp*p1;
        Fp2 = Fp'*p2;
        d_i = ((p2'* Fp1)^2)/(Fp1(1)^2+ Fp1(2)^2 + Fp2(1)^2+ Fp2(2)^2);
        if d_i < threshold
            inliers = [inliers, j];
        end
    end


    % Get F with most inliers
    if length(inliers) > length(final_inliers)
        final_inliers = inliers;
        F = Fp;
    end
end

% Denormalization
F = T2' * F * T1;
%NewInliersMatches = matches(:, inlier);
end