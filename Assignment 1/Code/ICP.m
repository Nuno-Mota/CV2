function subsampled_transformed_source = ICP(source, target, subsampling_method, ...
    number_of_points_to_keep, subsample_target, printing)
%ICP Summary of this function goes here
%   Detailed explanation goes here

if exist('subsampling_method')==0; subsampling_method = 'None'; end
if exist('number_of_points_to_keep')==0; number_of_points_to_keep = min(size(source,1),size(target,1)); end
if exist('subsample_target')==0; subsample_target = true; end
if exist('printing')==0; printing = true; end

subsampled_transformed_source = source;

[ms, rms] = ms_rms(source, target);
if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', 0, ms, rms); end

prev_rms = rms + 10;
i = 1;

while abs(prev_rms - rms) > 0.0005 && i < 250
    prev_rms = rms;

    if strcmp(subsampling_method, 'Random') == 1 || i == 1
        [subsampled_transformed_source, subsampled_target] = subsample(subsampled_transformed_source, target, subsampling_method, ...
            number_of_points_to_keep, subsample_target, printing);
    end

    indices = knnsearch(subsampled_target, subsampled_transformed_source);
    nearestNeighboursTarget = subsampled_transformed_source(indices,:);

    weights = ones(size(source(:,3)));
    [R, t] = RefineRT(nearestNeighboursTarget, subsampled_target, weights);

    subsampled_transformed_source = subsampled_transformed_source*R' + t';

    [ms, rms] = ms_rms(subsampled_transformed_source, subsampled_target);

    if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', i, ms, rms); end
    i = i + 1;
end

end