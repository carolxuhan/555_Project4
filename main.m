clear
tic

% Load data from folders

load data/river
F = size(colorMat,4);
c = size(colorMat,2);
r = size(colorMat,1);
p = c*r;

% Concatenate all the channels

vectorMat = zeros(3*p,F);
synthesizedMat = zeros(r,c,3,F);

for i=1:size(colorMat,4);
    vectorMat(:,i) = [ reshape(colorMat(:,:,1,i),[],1); ...
        reshape(colorMat(:,:,2,i),[],1); ...
        reshape(colorMat(:,:,3,i),[],1)];
end

toc

% Identify them as usual 

dParams.class = 2; 
sysParam = suboptimalSystemID(vectorMat,[50 20],dParams);
synthMat = generateFromLDS(sysParam,[size(vectorMat,1) 3*size(vectorMat,2)]);   

toc

% Once the synthesis is performed we unfold them
% and generating the images from the vector data

for i=1:size(synthMat,2);
    temp(:,:,1) = reshape(synthMat(1:p,i),[r c]);
    temp(:,:,2) = reshape(synthMat((1:p)+p,i),[r c]);
    temp(:,:,3) = reshape(synthMat((1:p)+2*p,i),[r c]);
    synthesizedMat(:,:,:,i) = temp;
end

toc

% Save the result as a video

writerObj = VideoWriter('awesomeMovie.mp4', 'MPEG-4');
open(writerObj);
for k=1:size(synthMat,2)
    masterFrame = uint8(synthesizedMat(:,:,:,k));
    f = im2frame(masterFrame);
    writeVideo(writerObj,f);
end
close(writerObj)

toc