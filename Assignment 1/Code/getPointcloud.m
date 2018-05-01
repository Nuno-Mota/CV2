function pointcloud = getPointcloud(number)
    pointcloud = readPcd(sprintf('Data/data/%010d.pcd', number));

    pointcloud = pointcloud(:,1:3);
    pointcloud = pointcloud(pointcloud(:,3)<2,:);
end