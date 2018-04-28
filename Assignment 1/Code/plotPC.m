function plotPC(plot_data, plot_name)
%PLOTPC Summary of this function goes here

figure('Name', plot_name)
fscatter3(plot_data)
xlabel('X')
ylabel('Y')
zlabel('Z')
end

