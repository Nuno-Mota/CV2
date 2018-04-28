clc

path_to_data_source = "Data/source.mat";
path_to_data_target = "Data/target.mat";

[source_data, target_data] = getExampleData(path_to_data_source, path_to_data_target);
plot_data = getPlotData(source_data, target_data);

plotPC(plot_data, 'Source vs. Target');

final_transformed_source = ICP(source_data, target_data);
plot_data = getPlotData(final_transformed_source, target_data);
plotPC(plot_data, 'Transformed Source vs. Target');