function res = MergingICP(frame_sampling_rate, num_images, method, sampling_method, num_points_to_keep)
    if exist('sampling_method')==0; sampling_method = 'Uniform'; end
    if exist('num_points_to_keep')==0; num_points_to_keep = -1; end
    if exist('method')==0; method = '3.1.a'; end
    if exist('num_images')==0; num_images = 99; end
    if exist('frame_sampling_rate')==0; frame_sampling_rate = 1; end
    start = frame_sampling_rate;

    source = getPointcloud(0);
    accumulated_PC = subsample(source, 0, 'Random', 10000, false, false);
    accumulated_PC(:, 4) = zeros(size(accumulated_PC(:,3)));
    num_classes = 0;

    for i = start:frame_sampling_rate:num_images
        num_classes = num_classes + 1;
        fprintf('IMAGE %2d OF %2d\n',i,num_images);

        target = getPointcloud(i);

        [R, t] = ICP(source, target, sampling_method, num_points_to_keep, true, false);

        transformed_source = subsample(source*R' + t', 0, 'Random', 10000, false, false);
        transformed_source(:, 4) = zeros(size(transformed_source(:,3)))+i-1;
        accumulated_PC = cat(1, accumulated_PC, transformed_source);


        if strcmp(method, '3.1.a') == 1 || strcmp(method, '3.1.b') == 1
            source = target;
        elseif strcmp(method, '3.2') == 1
            source = subsample(accumulated_PC(:,1:3), 0, 'Random', 10000, false, false);
        end
    end

    plot_data = tranformToPlotData(accumulated_PC, num_classes);
    plotPC(plot_data, 'Merged Data');

end