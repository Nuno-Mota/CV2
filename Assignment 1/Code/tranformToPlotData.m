function plot_data = tranformToPlotData(data, n_classes)
%GETPLOTDATA Summary of this function goes here

plot_data.x = data(:, 1);
plot_data.y = data(:, 2);
plot_data.z = data(:, 3);
plot_data.int = data(:, 4);
plot_data.n_classes = n_classes;
end

