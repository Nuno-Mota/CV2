function plot_data = getPlotData(source, target)
%GETPLOTDATA Summary of this function goes here

source(:,4) = zeros(size(source(:,3)));
target(:,4) = ones(size(target(:,3)));
plot = cat(1, source, target);

plot_data.x = plot(:, 1);
plot_data.y = plot(:, 2);
plot_data.z = plot(:, 3);
plot_data.int = plot(:, 4); clear plot;
end

