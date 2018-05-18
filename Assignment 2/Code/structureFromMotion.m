function structureFromMotion(parameters)

% Load/Create point view matrix
try
    %load('Data/point_view_matrix.mat', 'point_view_matrix');
    point_view_matrix = load('Data/PointViewMatrix.txt');
catch
    parameters.threshold = 1.0e-04;
    point_view_matrix = chain(parameters);
end


end