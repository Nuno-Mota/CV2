function [R, t] = RefineRT(p, q, w)
    % Compute the weighted centroids of both point sets:
    sum_w = sum(w);
    p_    = sum(p.*w)/sum_w;
    q_    = sum(q.*w)/sum_w;
    
    % Compute the centered vectors
    X     = p - p_;
    Y     = q - q_;
    
    % Compute the d×d covariance matrix
    W     = diag(w);
    S     = X*W*Y';
    
    % Compute the singular value decomposition S=UΣV'
    [U,~,V]= svd(S);
    
    % Compute the optimal rotation
    det_VUT= det(V*U');
    sizeV  = size(V,2);
    aux    = eye(size(V,2)); aux(sizeV,sizeV) = detVUT;
    R      = V*aux*U';

    % Compute the optimal translation
    t      = q_ - R*p_;
end