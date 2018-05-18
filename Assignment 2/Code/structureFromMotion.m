function [] = structureFromMotion(parameters)
%STRUCTUREFROMMOTION Summary of this function goes here
%   Detailed explanation goes here

% Load/Create point view matrix
try
    point_view_matrix = load(strcat(parameters.path_to_data, parameters.point_view_matrix_file));
    if strcmp(parameters.point_view_matrix_file, 'point_view_matrix.mat')
        point_view_matrix = point_view_matrix.point_view_matrix;
    end
catch
    disp('No previously generated matrix was found at provided data path:');
    disp(strcat(parameters.path_to_data, parameters.point_view_matrix_file));
    fprintf('Generating new one from scratch, using chain.m.\n\n');
    point_view_matrix = chain(parameters);
end



point_cloud = [];

if strcmp(parameters.denseblock_size, 'all')
    D = point_view_matrix;
    D(:,any(D==0,1))=[];
    normalised_denseD = D - sum(D, 2)/size(D, 2);
    [~, S] = getMotionShape(normalised_denseD);
    
    point_cloud = S;
    fscatter3(point_cloud(1,:), point_cloud(2,:),...
              parameters.visualization_z_scaling*point_cloud(3,:),...
              parameters.visualization_z_scaling*point_cloud(3,:));
end



end

