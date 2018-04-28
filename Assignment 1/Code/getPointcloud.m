function pc = getPointcloud(number)
    pc = readPcd(sprintf('Data/data/%010d.pcd', number));
    %dismiss 4th dimension
    pc = pc(:,1:3);
    %omit points further away than 2m
    pc = pc(pc(:,3)<2,:);
end