function sysParam = suboptimalSystemID(dataMatrix,order,params)
% Caclculates system parameters of LDS using suboptimal sysid  
%
% This function calculates the system parameters of a LDS that represents a video 
% sequence. This is the suboptimal approach proposed by Doretto et. al IJCV 2003.
%
% INPUTS
%   dataMatrix - p x F vector matrix or r x c x F sequence matrix
%   order      - [n nv] vector, [Default: nv=1]
%   params     - parameter structure containing the various parameters
%   .Rfull     - determines if the R matrix is returned as a full matrix
%              - or as a diagonal matrix [Default: 0].
%   .class     - determines the different subset of parameters that need
%              - to be identified [Default: 1]
%              - 1: Basic parameters,
%              - 2: Basic + noise parameters
%              - 3: All parameters
%   .Areg      - regularizes A to enforce stability (eig(A)<1) [Default: 1]
%
% OUTPUTS
%   sysParam   - output structure containing all the system parameters


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial Parameter Checks and Preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Checking the Data Matrix
F = size(dataMatrix,3);

if (size(dataMatrix,3)~=1)
    I = double(reshape(dataMatrix,[],F));
else
    F = size(dataMatrix,2);
    I = double(dataMatrix);
end

% Checking if we have noise order 
if length(order)==1
    n    = order(1);
    nv   = 1;
else
    n    = order(1);
    nv   = order(2);
end

% Parsing the parameter structure
dParams.Rfull = 0;
dParams.class = 1;
dParams.Areg  = 1;
if nargin<3
    params = dParams
else
    params        = testParamValidity(dParams,params);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creating Mean Subtracted sequence
C0         = mean(I,2);
Y          = I - repmat(C0,1,F);

% Perform SVD for the paramters
[U,S,V]    = svd(Y,0);
C          = U(:,1:n);
Z          = S(1:n,1:n)*V(:,1:n)';
A          = Z(:,2:F)*pinv(Z(:,1:(F-1)));
Z0         = Z(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regularizing A Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if params.Areg
[v,d] = eig(A);
e = abs(diag(d));
target = 0.9999;
if any(e>=target)
    foo = max(e);
    A = A*target/foo;
end 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Noise Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (params.class~=1)
    V          = Z(:,2:F) - A*Z(:,1:(F-1));
    [Uv,Sv,Vv] = svd(V,0);
    B          = Uv(:,1:nv)*Sv(1:nv,1:nv);
    B          = B./sqrt(F-1);
    Q          = B*B';
    W          = Y - C*Z;
    Rhat       = var(W(:));

    if params.Rfull
        R = zeros(size(W,1),size(W,1));
        R = Rhat.*eye(size(C,1));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forward Innovation Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (params.class==3)
    [P,L,G]    = dare(A',C',Q,R);
    K          = (A*P*C')*pinv(C*P*C'+R);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assigning Output Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sysParam.Z0    = Z0;
sysParam.A     = A;
sysParam.C     = C;
sysParam.Z     = Z;
sysParam.C0    = C0;
sysParam.class = params.class;

if (params.class~=1)
    sysParam.B    = B;
    sysParam.Q    = Q;    % Process Noise
    sysParam.Rhat = Rhat;
    if params.Rfull
        sysParam.R = R;    % Measurement Noise
    end
end

if (params.class==3)
    sysParam.K    = K;    
end
