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
section = '4';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.section = section;


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
    
    % Function call
    chain(parameters);

elseif strcmp(section, '5')
    % Pick desired parameters for part 5
    parameters.threshold = 1.0e-04;
    
    % Function call
    structureFromMotion(parameters);
    
%     error('Part 5 has not been implemented.')
end
