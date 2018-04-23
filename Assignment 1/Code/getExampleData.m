function [source_data, target_data, plot_data] = getExampleData(path_to_source, path_to_target);
% function source = getExampleData(path_to_source)


source = load(path_to_source); clear path_to_source;
source = source.source';
source(:,4) = zeros(size(source(:,3)));

target = load(path_to_target); clear path_to_target;
target = target.target';
target(:,4) = ones(size(target(:,3)));

plot = cat(1, source, target);

source_data.x = source(:, 1);
source_data.y = source(:, 2);
source_data.z = source(:, 3);
source_data.int = source(:, 4); clear source;

target_data.x = target(:, 1);
target_data.y = target(:, 2);
target_data.z = target(:, 3);
target_data.int = target(:, 4); clear target;

plot_data.x = plot(:, 1);
plot_data.y = plot(:, 2);
plot_data.z = plot(:, 3);
plot_data.int = plot(:, 4); clear plot;
end