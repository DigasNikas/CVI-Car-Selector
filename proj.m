close all;

path = 'CAMERA1_JPEGS_TRAINING\'; frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame = 3064;
step = 5;

img = imread('CAMERA1_JPEGS_TRAINING\0001.jpg');
bkg = zeros(size(img));

alfa = 0.01;
for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
   % imshow(img); drawnow
    y = img;
    bkg = alfa * double(y) + (1-alfa) * double(bkg);
    %imshow(uint8(bkg)); drawnow
end
imshow(uint8(bkg));

for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
    %imshow(uint8(bkg)); drawnow
end