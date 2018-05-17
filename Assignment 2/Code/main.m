clc

% Specify correct data path
parameters.path_to_data = 'Data/';

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
%
% ----- Part 5 - Structure from Motion

% write section as string
section = '3.2';
parameters.section = section;


if strcmp(section, '3.1') || strcmp(section, '3.2') || strcmp(section, '3.3')
    % Pick desired parameters for part 3
    parameters.img1_number = 1;
    parameters.img2_number = 2;
    parameters.draw_epipolar = true;
    
    if strcmp(section, '3.3')
        % Pick desired parameters for part 3.3
        parameters.threshold = 0;
    end
    
    fundamentalMatrix(parameters)
    
elseif strcmp(section, '4')
    % Pick desired parameters for part 4
elseif strcmp(section, '5')
    % Pick desired parameters for part 5
end
