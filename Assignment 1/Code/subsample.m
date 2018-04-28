function [sampled_transformed_source, sampled_target] = subsample(transformed_source, target, ...
    subsampling_method, percentage_of_points_to_keep_source, percentage_of_points_to_keep_target, print)
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
    size_target = size(target);
    size_target = size_target(1);
    
    source_points = linspace(1, size_source, size_source*percentage_of_points_to_keep_source/100);
    target_points = linspace(1, size_target, size_target*percentage_of_points_to_keep_target/100);
    
    sampled_transformed_source = transformed_source(source_points, :);
    sampled_target = target(target_points, :);
    return
    
    
    
elseif strcmp(subsampling_method, 'Random') == 1
    if print
        disp('Subsampling method = Random.');
    end
    
    size_source = size(transformed_source);
    size_source = size_source(1);
    size_target = size(target);
    size_target = size_target(1);
    
    source_points = randperm(size_source, size_source*percentage_of_points_to_keep_source/100);
    target_points = randperm(size_target, size_target*percentage_of_points_to_keep_target/100);
    
    sampled_transformed_source = transformed_source(source_points, :);
    sampled_target = target(target_points, :);
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

