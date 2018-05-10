clc

%run Code\'Supplementary Code'\vlfeat-0.9.21-bin\toolbox\vl_setup.m

img1_number = 1;
img2_number = 2;

img1 = getImageData(img1_number);
img2 = getImageData(img2_number);

computeFundamentalMatrixRANSAC(img1, img2);