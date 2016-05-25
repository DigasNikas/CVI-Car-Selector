close all;
clear;

path = 'CAMERA1_JPEGS_TRAINING\'; frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame = 3064;
step = 2;
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
%2781
InMov = 0;

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
    aux=struct('Area',0,'BoundingBox',[]);
    for prop = 1 : length(props)
        if (props(prop).Area > 150)
            aux(auxVar) = props(prop);
            auxVar = auxVar + 1;
        end
    end
    % ------ Excluir regioes pequenas -------- %
    
    imshow(imDiff);
    text(10,30,int2str(k),'color','r');
    if (k == 1) % Primeiro frame para as diferenças
        thatBB = cell(1, length(aux));
        for n = 1 : length(aux)
            thatBB{n} = aux(n).BoundingBox; % ThatBB --> Estrutura com BoundingBoxes do frame t-1
        end
    else
        if(aux(1).Area~=0)
            thisBB = cell(1,length(aux));
            for m = 1 : length(aux)
              thisBB{m} = aux(m).BoundingBox; % ThisBB --> Estrutura com BoundingBoxes do frame t
            end
            Matrix=zeros(length(thisBB),length(thatBB));
            for i = 1 : length(thisBB) % Verificar todas as diferenças entre as BB do frame t e t-1
                for j = 1 : length(thatBB)
                    DiffX = abs(thisBB{i}(1) - thatBB{j}(1));
                    DiffY = abs(thisBB{i}(2) - thatBB{j}(2));
                    Diff= sqrt(DiffX*DiffX + DiffY*DiffY);
                    if (Diff>1) && (Diff < 20) %Caso a diferença seja significativa, assinalar na Matrix
                        Matrix(i,j) = 1; 
                    else
                        Matrix(i,j) = 0;
                    end
                end
            end
            if(length(thisBB)>length(thatBB))
                %split
               'entrying'
            end
            if(length(thisBB)<length(thatBB))
                %pode acontecer merge
               'exiting'
            end
            Smatrix = cell(1, length(Matrix(:,1)));
            MMatrix = transpose(Matrix);

            for a = 1 : length(Matrix(:,1))
                pp = 1;
                for b = 1 : length(Matrix(1,:))
                    if (Matrix(a,b) == 1)
                        Smatrix{a}(pp) = b;
                        pp = pp + 1;
                    end
                end
            end

            Tmatrix = cell(1, length(MMatrix(:,1)));
            for a = 1 : length(MMatrix(:,1))
                pp = 1;
                for b = 1 : length(MMatrix(1,:))
                    if (MMatrix(a,b) == 1)
                        Tmatrix{a}(pp) = b;
                        pp = pp + 1;
                    end
                end
            end
    %         var = 0;
    %         for b = 1 : length(Tmatrix)
    %             if (Tmatrix(b) == length(Matrix))
    %                 var = 1;
    %             end
    %         end
    %         entering=0;
    %         if(var ==0)
    %             if (Smatrix(length(Matrix)) isempty)
    %                 entering=length(Matrix);
    %             end
    %         end


            for l = 1 : length(thisBB) % Tratar todas as regiões assinaladas na Matrix
                for c = 1 : length(thatBB)
                    if( Matrix(l,c) == 1) && (c==l)
                        if(thisBB{l}(3) < thisBB{l}(4)) % Caso sejam pessoas
                            rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','g','LineWidth',2 )
                            text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Person','color','g');
                        else % Caso sejam carros
                            rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','r','LineWidth',2 )
                            text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Car','color','r');
                        end
                        drawnow;
                    end
                end
            end
            thatBB = thisBB; % Preparar as BB do frame t para estarem presentes como t-1 no próximo frame
            clear aux;
        end
    end
    drawnow
end