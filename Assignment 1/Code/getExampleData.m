function [source_data, target_data] = getExampleData(path_to_source, path_to_target)

source = load(path_to_source); clear path_to_source;
source_data = source.source';

target = load(path_to_target); clear path_to_target;
target_data = target.target';
end