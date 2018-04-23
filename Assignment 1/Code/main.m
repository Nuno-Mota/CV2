path_to_data = "Data/data/0000000000.pcd";
data = readPcd(path_to_data)
%fscatter3(data(:, 1), data(:, 2), data(:, 3), data(:, 4))