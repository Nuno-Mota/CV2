function [motion, shape] = getMotionShape(dense_block)
%GETMOTIONSHAPE Summary of this function goes here
%   Detailed explanation goes here

[U , W , V] = svd(dense_block);
U3 = U(:, 1:3);
V3 = V(:, 1:3);
W3 = W(1:3,1:3);

motion = U3 * (W3^0.5);
shape = (W3^0.5) * V3';

end

