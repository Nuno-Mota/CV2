function [point_view_matrix] = chain(parameters)
%CHAIN Summary of this function goes here
%   Detailed explanation goes here

point_view_matrix = [];
current_descriptors = [];

flag_stop = false;

index_current_img = 1;
img_current = im2single(getImageData(index_current_img, parameters));
[f1,d1] = vl_sift(img_current);

for index_current_img=1:49
    
    img_number = index_current_img + 1;
    if index_current_img == 49
        flag_stop = true;
        img_number = 1;
    end
    if parameters.verbose
        fprintf('Currently working on image pair %d-%d\n', index_current_img, img_number);
    end

    img_next = im2single(getImageData(img_number, parameters));
    [f2,d2] = vl_sift(img_next);
    
    % Get matches provided by vlfeat
    [x1, y1, x2, y2, matches] = getMatches(f1, d1, f2, d2, parameters);
    
    % Get RANSAC estimation of Fundamental Matrix and Best Inliers
    [~, best_inliers] = normalizedEightPointAlgorithmRANSAC(x1, y1, x2, y2, parameters);
    
    [point_view_matrix, current_descriptors] = getPointViewMatrix(point_view_matrix, current_descriptors, matches, f1, f2, best_inliers, flag_stop);
    
    if flag_stop
        break
    end
    
    
    f1 = f2;
    d1 = d2;
end
save(strcat(parameters.path_to_data, 'point_view_matrix.mat'), 'point_view_matrix')

if parameters.display_PVM
    figure(1)
    imshow(point_view_matrix)
    figure(2)
    imagesc(point_view_matrix)
end
end

