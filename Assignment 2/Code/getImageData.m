function img = getImageData(img_number)
%GETIMAGEDATA Summary of this function goes here
%   Detailed explanation goes here

path_to_data = 'Data/';
img_path = strcat(path_to_data, sprintf('frame%08d.png', img_number));

img = imread(img_path);
end

