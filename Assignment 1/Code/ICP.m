function transformed_source = ICP(source, target, subsampling_method, ...
    num_points_to_keep, subsample_target, printing)
%ICP Summary of this function goes here
%   Detailed explanation goes here

if nargin == 5; printing = true; end

[ms, rms] = ms_rms(source, target);
fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', 0, ms, rms)


transformed_source = source;
prev_rms = rms + 10;
i = 1;

while abs(prev_rms - rms) > 0.0005 && i <= 250
    prev_rms = rms;

    if strcmp(subsampling_method, 'Random') == 1 || i == 1
        [sampled_transformed_source, sampled_target] = subsample(transformed_source, target,...
            subsampling_method, num_points_to_keep, subsample_target, printing, i);
    end
    
    indices = knnsearch(sampled_transformed_source, sampled_target);
    sampled_transformed_source = sampled_transformed_source(indices,:);

    weights = ones(size(sampled_transformed_source(:,3)));
    [R, t] = RefineRT(sampled_transformed_source, sampled_target, weights);

    sampled_transformed_source = sampled_transformed_source*R' + t';
    transformed_source = transformed_source*R' + t';

    [ms, rms] = ms_rms(transformed_source, target);
    if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', i, ms, rms), end
    i = i + 1;
end

end