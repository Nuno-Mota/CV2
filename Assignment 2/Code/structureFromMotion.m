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



end

