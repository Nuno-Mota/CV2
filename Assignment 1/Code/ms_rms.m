function [ms, rms] = ms_rms(transformed_source, target)
%Computes the Mean Square Error and the Root Mean Square Error
indices = knnsearch(target, transformed_source);
nearestNeighboursTarget = transformed_source(indices,:);

ms = mean(sum(((transformed_source - nearestNeighboursTarget).^2), 2));
rms = sqrt(ms);
end