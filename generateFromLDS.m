function [I,Z] = generateFromLDS(sysParam,vSize)
% Generate Video sequence from LDS Paramters
%
% This function generates a video sequnce given the paramters of the LDS for 
% any arbitary number of frames.
%
% INPUTS
%   sysParam - Structure containing the parameters of the LDS
%   vSize    - r x c x F denoting the size of the video sequence. 
%              Note that the r and c parameters must be conisten with the original
%              video sequence from which the LDS was identified.  
%
% OUTPUTS 
%   I        - Generated video sequence of size r x c x F
%   Z        - Hidden states of the model: n x F, where n is the model order.


%if sysParam.class==1
%    error('Minimal parameter set. Cannot generate output without noise parameters');
%end

structCheck = testStructContents(sysParam,{'A','C','Z0','B'}) || testStructContents(sysParam,{'A','C','Z0','K','R'});

if ~structCheck
  error('Missing Parameters. Cannot synthesize sequence');
end

C  = sysParam.C;
p  = size(C,1);

try
    C0 = sysParam.C0;
catch
    fprintf('Mean not present. Using zero mean\n');
    C0 = zeros(p,1);
end

A  = sysParam.A;
Z0 = sysParam.Z0;

BNoise = 1;
RNoise = 1;

if isfield(sysParam, 'B')
    B  = sysParam.B;
    RNoise = 0;
elseif isfield(sysParam, 'K') && isfield(sysParam, 'R')
    K = sysParam.K;
    R = sysParam.R;
    if size(R,1) ~= 1 && size(R,1) ~= size(K,2)
        error('Size of R matrix not consistent');
    end
    if size(R,1) == 1
        R = R*eye(size(K,2));
    end
    BNoise = 0;
end

if length(vSize)==3
    r = vSize(1)
    c = vSize(2)
    F = vSize(3);
    convertImage = 1;
else
    F = vSize(2);
    convertImage =0;
end
n = size(A,1);
if BNoise == 1 
    nv = size(B,2);
elseif RNoise == 1
    nv = size(K,2);
    B = K*chol(R, 'lower');
end

Z = zeros(n,F);
%I = zeros(p,F);

for i=1:F
    if i==1
        Z(:,i) = Z0;%A*Z0 + B*randn(nv,1);
    else
        Z(:,i) = A*Z(:,i-1) + B*randn(nv,1);
    end
    if convertImage
        I(:,:,i) = reshape(C*Z(:,i)+C0,[r c]);
    else
        I(:,i) = C*Z(:,i)+ C0;
    end
end
