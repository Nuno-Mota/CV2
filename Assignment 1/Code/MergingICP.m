function res = MergingICP(frame_sampling_rate, num_images, method)
    if exist('method')==0; method = 'normal'; end
    if exist('num_images')==0; num_images = 99; end
    if exist('frame_sampling_rate')==0; frame_sampling_rate = 1; end
    start = frame_sampling_rate+1;
    
    path_to_data_source = sprintf("Data/data/%010d.pcd",1);
    source = readPcd(path_to_data_source); clear path_to_data_source;

    for i = start:frame_sampling_rate:num_images

        path_to_data_target = sprintf("Data/data/%010d.pcd",i);

        target = readPcd(path_to_data_target);

        final_transformed_source = ICP(source, target, false);

        % Merge transformed source for plotting
        final_transformed_source(:,4) = zeros(size(final_transformed_source(:,3)));
        if exist('plot_data')==0
            plot_data = final_transformed_source;
        else
            plot_data = cat(1, plot_data, final_transformed_source);
        end


        if strcmp(method,'normal')==1; source = target; else, source = plot_data(:,1:3); end
    end

    plotPC(plot_data, 'Merged Data');
    res = 0;
end