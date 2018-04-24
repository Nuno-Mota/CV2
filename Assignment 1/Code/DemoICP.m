clc
%path_to_data = "Data/data/0000000000.pcd";
path_to_data_source = "Data/source.mat";
path_to_data_target = "Data/target.mat";

[source_data, target_data, plot_data] = getExampleData(path_to_data_source, path_to_data_target);

figure('Name', 'Source vs. Target')
fscatter3(plot_data)
xlabel('X')
ylabel('Y')
zlabel('Z')

figure('Name', 'Transformed Source vs. Target')
source = load(path_to_data_source); clear path_to_data_source;
source = source.source';
target = load(path_to_data_target); clear path_to_data_target;
target = target.target';
[R, t] = ICP(source, target);