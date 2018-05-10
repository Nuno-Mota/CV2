function fundamental_matrix = computeFundamentalMatrixRANSAC(img1,img2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

img1 = im2single(img1);
img2 = im2single(img2);


% 1. DETECT INTERESTING POINTS IN EACH IMAGE
[f1,d1] = vl_sift(img1);
[f2,d2] = vl_sift(img2);


% SHOW SIFT FEATURES AND DESCRIPTORS.

% imshow(img1);
% perm = randperm(size(f1,2)) ;
% sel = perm(1:500) ;
% h1 = vl_plotframe(f1(:,sel)) ;
% h2 = vl_plotframe(f1(:,sel)) ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;
% h3 = vl_plotsiftdescriptor(d1(:,sel),f1(:,sel)) ;
% set(h3,'color','g') ;


% 3. GET A SET OF SUPPOSED MATCHES BETWEEN REGION DESCRIPTORS IN EACH IMAGE
[matches, scores] = vl_ubcmatch(d1, d2) ;

matched_points1 = f1(1:2, matches(1, :))';
matched_points2 = f2(1:2, matches(2, :))';
x1 = matched_points1(:, 1);
y1 = matched_points1(:, 2);
x2 = matched_points2(:, 1);
y2 = matched_points2(:, 2);



% NO NEED TO IGNORE BACKGROUND. ONLY IF THERE IS TIME, AS IT WILL NOT BE
% GRADED. IF WE WANT TO DO SO:
% Option 1. Play around with SIFT hyperparameters.
% Option 2. Find a bounding box on the house. Ignore SIFT points outside
% the bounding box.
end
