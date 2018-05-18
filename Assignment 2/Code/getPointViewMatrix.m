function [point_view_matrix, current_descriptors] = getPointViewMatrix(point_view_matrix, current_descriptors, matches, f1, f2, best_inliers, flag_stop)
%GETPOINTVIEWMATRIX Summary of this function goes here
%   Detailed explanation goes here

f12_inliers = matches(:, best_inliers);

if size(point_view_matrix, 1) == 0
	current_descriptors = f12_inliers(1,:);
end

% Remove, relative to the last descriptors, those entries that are not in
% the new ones.
descriptors_except_new = setdiff(current_descriptors, f12_inliers(1, :));
current_descriptors(ismember(current_descriptors, descriptors_except_new)) = 0;

% Determine new descriptors
new_descriptors = setdiff(f12_inliers(1, :), current_descriptors);


num_new_descriptors = size(new_descriptors, 2);
current_descriptors(end + 1: end + num_new_descriptors) = new_descriptors;
if size(point_view_matrix, 1) ~= 0
	point_view_matrix(:, end + 1 : end + num_new_descriptors) = 0;
end


% Replace previous indices with the ones corresponding to the new image.
% Otherwise we wouldn't be able to compare for the next image pair.
new_current_descriptors = zeros(size(current_descriptors));
for i=1:size(f12_inliers, 2)
   new_current_descriptors(current_descriptors==f12_inliers(1, i))=f12_inliers(2, i);
end
current_descriptors = new_current_descriptors;

% Create new rows of the point view matrix
new_point_view_matrix_rows = zeros(2, size(current_descriptors, 2));
new_point_view_matrix_rows(:, current_descriptors > 0) = f2(1:2, current_descriptors(current_descriptors > 0));

if size(point_view_matrix, 1) == 0
	point_view_matrix = new_point_view_matrix_rows;
else
    point_view_matrix(end-1:end, end-num_new_descriptors+1:end) = f1(1:2, new_descriptors);
    if ~flag_stop
        point_view_matrix = vertcat(point_view_matrix, new_point_view_matrix_rows);
    else
        point_view_matrix(1:2, end-num_new_descriptors+1:end) = f2(1:2, new_current_descriptors(end-num_new_descriptors+1:end));
    end
end

end