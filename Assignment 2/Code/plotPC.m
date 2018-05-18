function [ ] = plotPC(point_cloud, parameters)
%PLOTPC Summary of this function goes here
%   Detailed explanation goes here

fscatter3(point_cloud(1,:), point_cloud(2,:),...
              parameters.visualization_z_scaling*point_cloud(3,:),...
              parameters.visualization_z_scaling*point_cloud(3,:));

if parameters.visualize_each_step
    hold on
end
end

