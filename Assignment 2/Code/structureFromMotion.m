function [] = structureFromMotion(parameters)
%STRUCTUREFROMMOTION Summary of this function goes here
%   Detailed explanation goes here

% Load/Create point view matrix
try
    point_view_matrix = load(strcat(parameters.path_to_data, parameters.point_view_matrix_file));
    if strcmp(parameters.point_view_matrix_file, 'point_view_matrix.mat')
        point_view_matrix = point_view_matrix.point_view_matrix;
    end
catch
    disp('No previously generated matrix was found at provided data path:');
    disp(strcat(parameters.path_to_data, parameters.point_view_matrix_file));
    fprintf('Generating new one from scratch, using chain.m.\n\n');
    point_view_matrix = chain(parameters);
end



point_cloud = [];

if strcmp(parameters.denseblock_size, 'all')
    D = point_view_matrix;
    D(:,any(D==0,1))=[];
    normalised_denseD = D - sum(D, 2)/size(D, 2);
    [~, S] = getMotionShape(normalised_denseD);
    
    point_cloud = S;
    fscatter3(point_cloud(1,:), point_cloud(2,:),...
              parameters.visualization_z_scaling*point_cloud(3,:),...
              parameters.visualization_z_scaling*point_cloud(3,:));
          
else
    num_consecutive_frames = str2num(parameters.denseblock_size);
    
    for i = 1:2*num_consecutive_frames:size(point_view_matrix, 1)
        
        final_frame = i + 2*num_consecutive_frames;
        if final_frame > size(point_view_matrix, 1)
            final_frame = size(point_view_matrix, 1);
        end
        
        D = point_view_matrix(i:final_frame, :);
        D(:,any(D==0,1))=[];
        normalised_denseD = D - sum(D, 2)/size(D, 2);
        [~, S] = getMotionShape(normalised_denseD);

        
        if i == 1
            point_cloud = S;
        else
            point_cloud = transformProcrustes(point_cloud, S);
        end
        
        if parameters.visualize_each_step
            plotPC(point_cloud, parameters)
        end
    end
    plotPC(point_cloud, parameters)
end



end

