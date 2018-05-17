function drawEpipolar(left_image, right_image, FM)
% This is an adapted version of draw_epipolar 
% found at http://ai.stanford.edu/~mitul/cs223b/fm.html
close all;
[m n] = size(left_image);
figure,imagesc(left_image);

[left_x, left_y] = ginput(1);

% Start plotting:

figure(1);
hold on;
plot(left_x, left_y, 'r*');

% Getting the epipolar line on the RIGHT image:

left_P = [left_x; left_y; 1];
right_P = FM*left_P;
right_epipolar_x = 1:2*m;

% Using the eqn of line: ax+by+c=0; y = (-c-ax)/b
right_epipolar_y = (-right_P(3)-right_P(1)*right_epipolar_x)/right_P(2);
figure,imagesc(right_image);
figure(2); hold on; plot(right_epipolar_x, right_epipolar_y, 'r'); plot(right_P(1), right_P(2), 'r*');


% Now finding the other epipolar line on the left image itself:

% We know that left epipole is the 3rd column of V.
% We get V from svd of F. F=UDV'

[FU, FD, FV] = svd(FM);
left_epipole = FV(:,3);
left_epipole = left_epipole/left_epipole(3);

% Hence using the left epipole and the given input point on left
% image we plot the epipolar line on the left image
left_epipolar_x = 1:2*m;
left_epipolar_y = left_y + (left_epipolar_x-left_x)*(left_epipole(2)-left_y)/(left_epipole(1)-left_x);

figure(1); hold on; plot(left_epipolar_x, left_epipolar_y, 'r');

end