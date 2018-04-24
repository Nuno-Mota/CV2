clc

path_to_data_source = "Data/source.mat";
path_to_data_target = "Data/target.mat";

source = load(path_to_data_source); clear path_to_source;
source = source.source';

target = load(path_to_data_target); clear path_to_target;
target = target.target';

[R, t] = ICP(source, target);