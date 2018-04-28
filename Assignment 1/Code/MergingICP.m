function res = MergingICP(frame_sampling_rate, num_images)
    if exist('num_images')==0; num_images = 99; end
    if exist('frame_sampling_rate')==0; frame_sampling_rate = 1; end
    start = frame_sampling_rate+1;
    
    path_to_data_source = sprintf("Data/data/%010d.pcd",1);
    source = readPcd(path_to_data_source); clear path_to_data_source;

    for i = start:frame_sampling_rate:num_images

        path_to_data_target = sprintf("Data/data/%010d.pcd",i);

        target = readPcd(path_to_data_target);

        [R, t] = ICP(source, target, false);

        source = target;
    end
end