function [total_R, total_t] = ICP(source, target, subsampling_method, ...
    num_points_to_keep, subsample_target, printing)
%ICP Summary of this function goes here
%   Detailed explanation goes here
if exist('subsampling_method')==0; subsampling_method = 'None'; end
if exist('num_points_to_keep')==0 || num_points_to_keep==-1; num_points_to_keep = min(size(source,1),size(target,1)); end
if exist('subsample_target')==0; subsample_target = true; end
if exist('printing')==0; printing = true; end


[ms, rms] = ms_rms(source, target);
if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', 0, ms, rms); end


total_R = eye(3);
total_t = zeros([3 1]);

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
    aux = sampled_transformed_source(indices,:);

    weights = ones(size(aux(:,3)));
    [R, t] = RefineRT(aux, sampled_target, weights);
    total_R = (total_R'*R')';
    total_t = (total_t'*R' + t')';
    

    sampled_transformed_source = sampled_transformed_source*R' + t';
    transformed_source = transformed_source*R' + t';
    
    [ms, rms] = ms_rms(source*total_R' + total_t', target);
    if printing; fprintf('Iteration: %3d ||| MS : %.5f ||| RMS : %.5f\n', i, ms, rms); end
    i = i + 1;
end

end