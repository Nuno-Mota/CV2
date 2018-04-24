function [R, t] = RefineRT(p, q, w)
    % Compute the weighted centroids of both point sets:
    sum_w = sum(w);
    p_    = sum(p.*w, 1)/sum_w;
    q_    = sum(q.*w, 1)/sum_w;
    
    % Compute the centered vectors
    X     = p - p_;
    Y     = q - q_;
    
    % Compute the d×d covariance matrix
    W     = diag(w);
    S     = X'*W*Y;
    
    % Compute the singular value decomposition S=UΣV'
    [U,~,V]= svd(S);
    
    % Compute the optimal rotation
    det_VUT= det(V*U');
    sizeV  = size(V,2);
    aux    = eye(sizeV); aux(sizeV,sizeV) = det_VUT;
    R      = V*aux*U';

    % Compute the optimal translation
    t      = q_' - R*p_';
end