function transformed_source = ICP(source, target, subsampling_method, ...
    percentage_of_points_to_keep_source, percentage_of_points_to_keep_target, printing)
%ICP Summary of this function goes here
%   Detailed explanation goes here

if nargin == 5; printing = true; end

transformed_source = source;

[transformed_source, target] = sumbsample(transformed_source, target, subsampling_method, ...
    percentage_of_points_to_keep_source, percentage_of_points_to_keep_target);

indices = knnsearch(target, transformed_source);
nearestNeighboursTarget = transformed_source(indices,:);

[ms, rms] = ms_rms(source, nearestNeighboursTarget);
fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', 0, ms, rms)


prev_rms = rms + 10;
i = 1;

while abs(prev_rms - rms) > 0.0005 && i < 250
    prev_rms = rms;

    [transformed_source, target] = sumbsample(transformed_source, target, subsampling_method, ...
        percentage_of_points_to_keep_source, percentage_of_points_to_keep_target);

    indices = knnsearch(target, transformed_source);
    nearestNeighboursTarget = transformed_source(indices,:);

    weights = ones(size(source(:,3)));
    [R, t] = RefineRT(nearestNeighboursTarget, target, weights);

    transformed_source = transformed_source*R' + t';

    indices = knnsearch(target, transformed_source);
    nearestNeighboursTarget = transformed_source(indices,:);
    [ms, rms] = ms_rms(transformed_source, nearestNeighboursTarget);

    if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', i, ms, rms), end
    i = i + 1;
end

end