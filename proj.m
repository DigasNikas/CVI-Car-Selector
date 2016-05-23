close all;
clear;

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
     
    imDiff = (abs(double(img(:,:,1)) - double(bkg(:,:,1))) > th) |...
             (abs(double(img(:,:,2)) - double(bkg(:,:,2))) > th) |...
             (abs(double(img(:,:,3)) - double(bkg(:,:,3))) > th);
    
    imDiff = medfilt2(imDiff);
    imDiff = bwareaopen(imDiff, 20, 8);
    imDiff = bwconvhull(imDiff, 'objects');
    imDiff = bwmorph(imDiff,'fill');
    
    [lb num] = bwlabel(imDiff);
    props = regionprops(lb,'BoundingBox', 'Area');
    
    auxVar = 1;
    for prop = 1 : length(props)
        if (props(prop).Area > 100)
            aux(auxVar) = props(prop);
            auxVar = auxVar + 1;
        end
    end
    
    imshow(img);
    text(10,30,int2str(k),'color','r');
    
    if (k == 1)
        thatBB = cell(1, length(aux));
        for n = 1 : length(aux)
            thatBB{n} = aux(n).BoundingBox;
        end
    else
        thisBB = cell(1,length(aux));
        for m = 1 : length(aux)
          thisBB{m} = aux(m).BoundingBox;
        end
        for i = 1 : length(thisBB)
            for j = 1 : length(thatBB)
                Diff = norm(thisBB{i} - thatBB{j},1);
                if ( 8 < Diff )
                    Matrix(i,j) = 1;
                else
                    Matrix(i,j) = 0;
                end
            end
        end
        for l = 1 : length(thisBB)
            if( Matrix(l,:) == 1)
                rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','r','LineWidth',2 )
                text(thisBB{l}(1)-10,thisBB{l}(2)-10,int2str(l),'color','r');
                drawnow;
            end
        end
        thatBB = thisBB;
    end

    drawnow
end