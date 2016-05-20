close all;

path = 'CAMERA1_JPEGS_TRAINING\'; frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame = 3064;
step = 5;
th = 30;

img = imread('CAMERA1_JPEGS_TRAINING\0001.jpg');
bkg = zeros(size(img));

alfa = 0.01;
for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
    y = img;
    bkg = alfa * double(y) + (1-alfa) * double(bkg);
end

for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
    se = offsetstrel('ball',5,5);
    
    imDiff = (abs(double(img(:,:,1)) - double(bkg(:,:,1))) > th) | (abs(double(img(:,:,2)) - double(bkg(:,:,2))) > th) | (abs(double(img(:,:,3)) - double(bkg(:,:,3))) > th);
    
    imDiff = medfilt2(imDiff);
    imDiff = bwconvhull(imDiff, 'objects');
    %imDiff = imopen(imDiff, strel('disk',2));
    %imDiff = imfill(imDiff, 'holes');
    
    props = regionprops(imDiff,'BoundingBox', 'Area','MajorAxisLength');
    
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
    imshow(img);
    
    text(10,30,int2str(k),'color','r');
    for k = 1 : length(props)
      thisBB = props(k).BoundingBox;
      if(props(k).Area > 100)
        rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 )
      end
    end
    drawnow
end