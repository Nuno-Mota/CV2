function [x, y, T] = normalizeData(x, y)

mx = mean(x);
my = mean(y);
d = mean(sqrt(((x - mx).^2) + ((y - my).^2)));
sqrt2d = sqrt(2)/d;
T = [sqrt2d, 0, -mx*sqrt2d; 0, sqrt2d, -my*sqrt2d; 0, 0, 1];
xy = [x, y, ones(size(x))]';
xy = T * xy;
x = xy(1, :)';
y = xy(2, :)';

end