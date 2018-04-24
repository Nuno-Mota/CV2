clc

path_to_data_source = sprintf("Data/data/%010d.pcd",1);
source = readPcd(path_to_data_source); clear path_to_data_source;

num_images = 99;
for i=2:num_images
    path_to_data_target = sprintf("Data/data/%010d.pcd",i);

    target = readPcd(path_to_data_target);

    [R, t] = ICP(source, target, false);

    source = target;
end