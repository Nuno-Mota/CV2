function [source_data, target_data] = getExampleData(path_to_source, path_to_target)

source = load(path_to_source);
clear path_to_source;
source = source.source';

target = load(path_to_target);
clear path_to_target;
target = target.target';

source_data.x = source(:, 1);
source_data.y = source(:, 2);
source_data.z = source(:, 3);
clear source;

target_data.x = target(:, 1);
target_data.y = target(:, 2);
target_data.z = target(:, 3);
clear target;
end

