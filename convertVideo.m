clear
x = VideoReader('waterfall.mp4');
colorMat = read(x);
save('waterfall.mat','colorMat');