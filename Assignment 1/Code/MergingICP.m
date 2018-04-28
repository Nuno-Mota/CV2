function res = MergingICP(frame_sampling_rate, num_images, method, sampling_method, num_points_to_keep)
    if exist('sampling_method')==0; sampling_method = 'None'; end
    if exist('num_points_to_keep')==0; num_points_to_keep = 500; end
    if exist('method')==0; method = 'normal'; end
    if exist('num_images')==0; num_images = 99; end
    if exist('frame_sampling_rate')==0; frame_sampling_rate = 1; end
    start = frame_sampling_rate;

    source = getPointcloud(0);

    for i = start:frame_sampling_rate:num_images
        fprintf('IMAGE %2d OF %2d\n',i,num_images);

        target = getPointcloud(i);

        final_transformed_source = ICP(source, target, sampling_method, num_points_to_keep, true, false);

        % Merge transformed source for plotting
        final_transformed_source(:,4) = zeros(size(final_transformed_source(:,3)))+i;
        if exist('plot_data')==0
            plot_data = final_transformed_source;
        else
            plot_data = cat(1, plot_data, final_transformed_source);
        end


        if strcmp(method,'normal')==1
            source = target;
        else
            source = subsample(plot_data(:,1:3), plot_data(:,1:3), 'Random', 5000, false, false);
        end
    end

    size(plot_data)
%     [~, plot_data] = subsample(plot_data, plot_data, 'Uniform', 100000, true, false, 1);
    plot_data = tranformToPlotData(plot_data);
    plotPC(plot_data, 'Merged Data');
    res = 0;
end