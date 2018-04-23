clc
%path_to_data = "Data/data/0000000000.pcd";
path_to_data_source = "Data/source.mat";
path_to_data_target = "Data/target.mat";

[source_data, target_data] = getExampleData(path_to_data_source, path_to_data_target);


fscatter3(source_data)
fscatter3(target_data)