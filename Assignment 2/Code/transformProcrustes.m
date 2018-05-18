function [point_cloud] = transformProcrustes(point_cloud, S, indices_points_kept, new_indices, parameters)
%TRANSFORMPROCRUSTES Summary of this function goes here
%   Detailed explanation goes here

common_points = intersect(indices_points_kept, new_indices);

common_old_indices = find(ismember(indices_points_kept, common_points));
common_new_indices = find(ismember(new_indices, common_points));
different_new_indices = find(~ismember(new_indices, common_points));

common_old_points = point_cloud(:, common_old_indices);
common_new_points = point_cloud(:, common_new_indices);

[~, ~, transformation_new_points] = procrustes(common_old_points', common_new_points');

transformed_new_points_transposed = transformation_new_points.b*S'*transformation_new_points.T +...
                                    sum(transformation_new_points.c, 1)/size(transformation_new_points.c, 1);
transformed_new_points = transformed_new_points_transposed';

if strcmp(parameters.replace_same_points, 'new')
    point_cloud(:, common_old_indices) = transformed_new_points(:, common_new_indices);
end
point_cloud(:, end+1:end + size(different_new_indices, 2)) = transformed_new_points(:, different_new_indices);
end

