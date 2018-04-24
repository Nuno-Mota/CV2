function [R, t] = ICP(source, target)
%ICP Summary of this function goes here
%   Detailed explanation goes here

% Initialization of R and t
R = eye(3);
t = zeros(3,1);

transformed_source = source;


% Find matching indices from transformed_source to target



% while true

indices = knnsearch(target, transformed_source);
nearestNeighboursTarget = transformed_source(indices,:);

rms = sqrt(mean(sum((nearestNeighboursTarget - transformed_source).^2), 2))

weights = ones(size(source(:,3)));
[R, t] = RefineRT(nearestNeighboursTarget, target, weights);

transformed_source = transformed_source*R' + t';

indices = knnsearch(target, transformed_source);
nearestNeighboursTarget = transformed_source(indices,:);
rms = sqrt(mean(sum((nearestNeighboursTarget - transformed_source).^2), 2))
    
    


end

