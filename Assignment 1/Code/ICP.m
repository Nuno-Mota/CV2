function [R, t] = ICP(source, target)
%ICP Summary of this function goes here
%   Detailed explanation goes here

% Initialization of R and t
R = eye(3);
t = zeros(3,1);

transformed_source = source;

indices = knnsearch(target, transformed_source);
nearestNeighboursTarget = transformed_source(indices,:);
rms = sqrt(mean(sum((nearestNeighboursTarget - transformed_source).^2), 2));
prev_rms = rms + 0.51;
i = 1;
% Find matching indices from transformed_source to target

while abs(prev_rms - rms) > 0.05 & i<250
    prev_rms = rms;

    indices = knnsearch(target, transformed_source);
    nearestNeighboursTarget = transformed_source(indices,:);

    weights = ones(size(source(:,3)));
    [R, t] = RefineRT(nearestNeighboursTarget, target, weights);

    transformed_source = transformed_source*R' + t';

    indices = knnsearch(target, transformed_source);
    nearestNeighboursTarget = transformed_source(indices,:);
    rms = sqrt(mean(sum((nearestNeighboursTarget - transformed_source).^2), 2));

    fprintf('RMS %i: %f\n',i,abs(prev_rms - rms));
    i = i + 1;
end

% Print final result against target value
target(:,4) = zeros(size(target(:,3)));
transformed_source(:,4) = ones(size(transformed_source(:,3)));
plot = cat(1, transformed_source, target);

plot_data.x = plot(:, 1);
plot_data.y = plot(:, 2);
plot_data.z = plot(:, 3);
plot_data.int = plot(:, 4); clear plot;

fscatter3(plot_data);

end

