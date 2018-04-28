function [ms, rms] = ms_rms(transformed_source, target)
%Computes the Mean Square Error and the Root Mean Square Error
indices = knnsearch(transformed_source, target);
transformed_source = transformed_source(indices,:);

ms = mean(sum(((transformed_source - target).^2), 2));
rms = sqrt(ms);
end