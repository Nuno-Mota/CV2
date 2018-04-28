function [sampled_transformed_source, sampled_target] = subsample(transformed_source, target, ...
    subsampling_method, number_of_points_to_keep, subsample_target, print)
%SUBSAMPLE Summary of this function goes here

if strcmp(subsampling_method, 'None') == 1
    if print
        disp('Subsampling method = None. No subsampling performed.');
    end
    sampled_transformed_source = transformed_source;
    sampled_target = target;
    return
    
elseif strcmp(subsampling_method, 'Uniform') == 1
    if print
        disp('Subsampling method = Uniform.');
    end
    
    size_source = size(transformed_source);
    size_source = size_source(1);
    source_points = randperm(size_source, number_of_points_to_keep);
    sampled_transformed_source = transformed_source(source_points, :);
    
    if subsample_target
        size_target = size(target);
        size_target = size_target(1);
        target_points = randperm(size_target, number_of_points_to_keep);
        sampled_target = target(target_points, :);
    else
        sampled_target = target;
    end
    return
    
    
    
elseif strcmp(subsampling_method, 'Random') == 1
    if print
        disp('Subsampling method = Random.');
    end
    
    size_source = size(transformed_source);
    size_source = size_source(1);
    source_points = randperm(size_source, number_of_points_to_keep);
    sampled_transformed_source = transformed_source(source_points, :);
    
    if subsample_target
        size_target = size(target);
        size_target = size_target(1);
        target_points = randperm(size_target, number_of_points_to_keep);
        sampled_target = target(target_points, :);
    else
        sampled_target = target;
    end
    return
    
elseif strcmp(subsampling_method, 'Informed') == 1
%     if print
%         disp('Subsampling method = Informed.');
%     end
    disp('Subsampling method = Informed. Method has not been implemented. No subsampling performed.');
    return
else
    disp('Unknown subsampling method. No subsampling performed.');
    return
end

