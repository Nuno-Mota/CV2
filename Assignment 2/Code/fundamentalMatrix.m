function [fundamental_matrix, best_inliers] = fundamentalMatrix(parameters)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
best_inliers = 0;

% Load images from memory
img1 = getImageData(parameters.img1_number, parameters);
img2 = getImageData(parameters.img2_number, parameters);

% Convert images to single precision, for vlfeat
img1 = im2single(img1);
img2 = im2single(img2);

% DETECT INTERESTING POINTS IN EACH IMAGE
[f1,d1] = vl_sift(img1);
[f2,d2] = vl_sift(img2);

% Get matches provided by vlfeat
[x1, y1, x2, y2, ~] = getMatches(f1, d1, f2, d2, parameters);

% ESTIMATE THE FUNDAMENTAL MATRIX FOR THE GIVEN TWO IMAGES
if strcmp(parameters.section, '3.1')
	fundamental_matrix = eightPointAlgorithm(x1, y1, x2, y2);
elseif strcmp(parameters.section, '3.2')
    fundamental_matrix = normalizedEightPointAlgorithm(x1, y1, x2, y2);
else
    [fundamental_matrix, best_inliers] = normalizedEightPointAlgorithmRANSAC(x1, y1, x2, y2, parameters);
end

if parameters.draw_epipolar
    drawEpipolar(img1, img2, fundamental_matrix);
end

% NO NEED TO IGNORE BACKGROUND. ONLY IF THERE IS TIME, AS IT WILL NOT BE
% GRADED. IF WE WANT TO DO SO:
% Option 1. Play around with SIFT hyperparameters.
% Option 2. Find a bounding box on the house. Ignore SIFT points outside
% the bounding box.
end

