function img = getImageData(img_number, parameters)
%GETIMAGEDATA Summary of this function goes here
%   Detailed explanation goes here


img_path = strcat(parameters.path_to_data, sprintf('frame%08d.png', img_number));

img = imread(img_path);

end

