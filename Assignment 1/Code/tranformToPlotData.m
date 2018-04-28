function plot_data = tranformToPlotData(data)
%GETPLOTDATA Summary of this function goes here

if size(data,2) == 3; data(:,4) = zeros(size(data(:,3))); end
plot_data.x = data(:, 1);
plot_data.y = data(:, 2);
plot_data.z = data(:, 3);
plot_data.int = data(:, 4); clear plot;
end

