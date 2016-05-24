close all;
clear;

path = 'CAMERA1_JPEGS_TRAINING\'; frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame = 3064;
step = 5;
th = 30;

img = imread('CAMERA1_JPEGS_TRAINING\0001.jpg');
bkg = zeros(size(img));

% ------ Background -------- %
alfa = 0.01;
for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
    y = img;
    bkg = alfa * double(y) + (1-alfa) * double(bkg);
end
% ------ Background -------- %

% ------ Comparação frame t / frame t-1 -------- %
for k=1 : step : nFrame
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
     
    % Calcular a imagem binaria
    imDiff = (abs(double(img(:,:,1)) - double(bkg(:,:,1))) > th) |...
             (abs(double(img(:,:,2)) - double(bkg(:,:,2))) > th) |...
             (abs(double(img(:,:,3)) - double(bkg(:,:,3))) > th);
         
    % Operações de limpeza
    imDiff = medfilt2(imDiff);
    imDiff = bwareaopen(imDiff, 20, 8);
    imDiff = bwconvhull(imDiff, 'objects');
    imDiff = bwmorph(imDiff,'fill');
    
    [lb, num] = bwlabel(imDiff);
    props = regionprops(lb,'BoundingBox', 'Area');
    
    
    % ------ Excluir regioes pequenas --------%
    auxVar = 1;
    for prop = 1 : length(props)
        if (props(prop).Area > 150)
            aux(auxVar) = props(prop);
            auxVar = auxVar + 1;
        end
    end
    % ------ Excluir regioes pequenas -------- %
    
    imshow(img);
    text(10,30,int2str(k),'color','r');
    
    if (k == 1) % Primeiro frame para as diferenças
        thatBB = cell(1, length(aux));
        for n = 1 : length(aux)
            thatBB{n} = aux(n).BoundingBox; % ThatBB --> Estrutura com BoundingBoxes do frame t-1
        end
    else
        thisBB = cell(1,length(aux));
        for m = 1 : length(aux)
          thisBB{m} = aux(m).BoundingBox; % ThisBB --> Estrutura com BoundingBoxes do frame t
        end
        for i = 1 : length(thisBB) % Verificar todas as diferenças entre as BB do frame t e t-1
            for j = 1 : length(thatBB)
                Diff = norm(thisBB{i} - thatBB{j},1);
                if ( 8 < Diff ) %Caso a diferenças seja significativa, assinalar na Matrix
                    Matrix(i,j) = 1;
                else
                    Matrix(i,j) = 0;
                end
            end
        end
        for l = 1 : length(thisBB)
            if( Matrix(l,:) == 1)
                if(thisBB{l}(3) < thisBB{l}(4))
                    rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','g','LineWidth',2 )
                    text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Person','color','g');
                else
                    rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','r','LineWidth',2 )
                    text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Car','color','r');
                end
                drawnow;
            end
        end
        thatBB = thisBB;
    end

    drawnow
end