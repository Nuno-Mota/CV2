function plotPC(plot_data, plot_name)
%PLOTPC Summary of this function goes here

figure('Name', plot_name)


X = plot_data.x;
Y = plot_data.y;
Z = plot_data.z;
% C = plot_data.int;
C = plot_data.z;
numclass = plot_data.n_classes;

clear plot_data;

if numclass > 2
    numclass = 256;
    cmap = hsv(256);
else
    cmap = [0. 0. 0.6
        1. 0.6 0.];
end
siz = 5;


mins = min(C);
maxs = max(C);
minz = min(Z);
maxz = max(Z);
minx = min(X);
maxx = max(X);
miny = min(Y);
maxy = max(Y);

% construct colormap :

col = cmap;

% determine index into colormap

ii = floor( (C - mins ) * (numclass-1) / (maxs - mins) );
ii = ii + 1;

colormap(cmap);

hold on
k = 0;o = k;
for j = 1:numclass
  jj = (ii(:)== j);
  if ~isempty(jj)
    k = k + 1;
    h = plot3(X(jj),Y(jj),Z(jj),'.','color',col(j,:),'markersize',siz);
    if ~isempty(h)
      o = o+1;
        hp(o) = h;
    end
  end  
end
caxis([min(C) max(C)]);
axis equal;rotate3d on;view(3);
box on
hcb = colorbar('location','east');


xlabel('X')
ylabel('Y')
zlabel('Z')
end

