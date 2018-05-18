function [x1, y1, x2, y2, matches] = getMatches(f1, d1, f2, d2, parameters)
%GETMATCHES Summary of this function goes here
%   Detailed explanation goes here


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


% GET A SET OF SUPPOSED MATCHES BETWEEN REGION DESCRIPTORS IN EACH IMAGE
[matches, scores] = vl_ubcmatch(d1, d2) ;
matched_points1 = f1(1:2, matches(1, :))';
matched_points2 = f2(1:2, matches(2, :))';
x1 = matched_points1(:, 1);
y1 = matched_points1(:, 2);
x2 = matched_points2(:, 1);
y2 = matched_points2(:, 2);

end

