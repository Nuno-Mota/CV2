function [ ] = plotPointViewMatrix(point_view_matrix)
%PLOTPOINTVIEWMATRIX Summary of this function goes here
%   Detailed explanation goes here

repeat_count = int64(size(point_view_matrix, 2)/size(point_view_matrix, 1));
    pointview_extended = zeros(size(point_view_matrix, 1)*repeat_count, size(point_view_matrix, 2));
    for pointview_row_ind = 1:(size(point_view_matrix, 1))
        for copy_row_ind = ((pointview_row_ind-1)*repeat_count)+1:((pointview_row_ind-1)*repeat_count+repeat_count)
            pointview_extended(copy_row_ind, :) = point_view_matrix(pointview_row_ind,:);
        end
    end
    clf
    imshow(pointview_extended)
end

