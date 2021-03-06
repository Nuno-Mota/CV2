clc

% Specify correct data path
parameters.path_to_data = 'Assignment 2/Data/';

% Specify the section number to run.
% Choose from: {3.1, 3.2, 3.3, 4, 5}
%
% ----- Part 3 - Fundamental Matrix
% --------parameters to configure: select img1 and img2 numbers (according
%                                  to the dataset)
% ---------------section=3.1 - Basic Eight Point Algorithm
% ---------------section=3.2 - Normalised Eight Point Algorithm
% ---------------section=3.3 - Normalised Eight Point Algorithm with RANSAC
% ---------------------parameters to configure: threshold
%
% ----- Part 4 - Chaining
% --------parameters to configure: threshold (for RANSAC)
%
% ----- Part 5 - Structure from Motion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose section value from: {3.1, 3.2, 3.3, 4, 5}
section = '5';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.section = section;

parameters.verbose = true;


if strcmp(section, '3.1') || strcmp(section, '3.2') || strcmp(section, '3.3')
    % Pick desired parameters for part 3
    parameters.img1_number = 1;
    parameters.img2_number = 25;
    parameters.draw_epipolar = true;
    
    if strcmp(section, '3.3')
        % Pick desired parameters for part 3.3
        parameters.threshold = 1.0e-04;
    end
    
    % Function call
    fundamentalMatrix(parameters);
    
elseif strcmp(section, '4')
    % Pick desired parameters for part 4
    parameters.threshold = 1.0e-04;
    parameters.display_PVM = true;
    
    % Function call
    chain(parameters);

elseif strcmp(section, '5')
    % Pick desired parameters for part 5
    parameters.threshold = 1.0e-04; % (for RANSAC, if necessary to generate new point view matrix).
    parameters.display_PVM = false; % (if necessary to generate new point view matrix).
    
    % TODO: When loading the sample file, points seem to be inverted on Z axis
    parameters.point_view_matrix_file = 'point_view_matrix.mat'; % Load either generated matrix with chain.m ('point_view_matrix.mat') or sample matrix ('PointViewMatrix.txt')
    parameters.denseblock_size = 'all'; % Choose from {'all', '3', '4', (or other value not specified in the assignment)}, representing the number of frames per dense block.
    parameters.visualization_z_scaling = 1.5; % scaling on the z simension to better discern the 3D points
    parameters.visualize_each_step = true; % parameter to specify whether to show the transformation on each iterative step
    parameters.replace_same_points = 'new'; % parameter to specify whether to replace old common points to both the old point cloud and the new point cloud with pointsfrom the new point cloud. If that's not desired write anything else other than 'new'
    
    % Function call
    structureFromMotion(parameters);
else
    error('Section value provided (%s) is unknown. Please choose one from {3.1, 3.2, 3.3, 4, 5}. Read beginning of main.m.', section);
end
