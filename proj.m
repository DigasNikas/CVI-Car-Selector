close all;
clear;

path = 'CAMERA1_JPEGS_TESTING\'; frameIdComp = 4;
str = ['%s%.' num2str(frameIdComp) 'd.%s'];

nFrame =2688; %3064; %2688;
step = 4;
th = 40;

img = imread('CAMERA1_JPEGS_TESTING\0001.jpg');
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

for k=170 : step : nFrame - 20
    strl = sprintf(str, path,k,'jpg');
    img = imread(strl);
     
    % Calcular a imagem binaria
    imDiff = (abs(double(img(:,:,1)) - double(bkg(:,:,1))) > th) |...
             (abs(double(img(:,:,2)) - double(bkg(:,:,2))) > th) |...
             (abs(double(img(:,:,3)) - double(bkg(:,:,3))) > th);
         
    % Operações de limpeza
    imDiff = medfilt2(imDiff);
    imDiff = imerode(imDiff, strel('disk',2));
    imDiff = imdilate(imDiff, strel('disk',10));
    imDiff = bwconvhull(imDiff, 'objects');
    imDiff = imclose(imDiff, strel('disk',4));
    
    [lb, num] = bwlabel(imDiff);
    props = regionprops(lb,'BoundingBox', 'Area','Centroid');
    
    
    % ------ Excluir regioes pequenas --------%
    auxVar = 1;
    aux=struct('Area',0,'Centroid',[],'BoundingBox',[]);
    for prop = 1 : length(props)
        if (props(prop).Area > 500)
            aux(auxVar) = props(prop);
            auxVar = auxVar + 1;
        end
    end
    % ------ Excluir regioes pequenas -------- %
    
    imshow(img);
    text(10,30,int2str(k),'color','r');
    if (k == 170) % Primeiro frame para as diferenças
        thatBB = cell(1, length(aux));
        thatCC = cell(1, length(aux));
        PreMaster = [];
        for n = 1 : length(aux)
            thatBB{n} = aux(n).BoundingBox; % ThatBB --> Estrutura com BoundingBoxes do frame t-1
            thatCC{n} = aux(n).Centroid;
        end
    else
        if(aux(1).Area~=0)
            thisBB = cell(1,length(aux));
            thisCC = cell(1,length(aux));
            for m = 1 : length(aux)
              thisBB{m} = aux(m).BoundingBox; % ThisBB --> Estrutura com BoundingBoxes do frame t
              thisCC{m} = aux(m).Centroid;
            end
            vel=zeros(length(aux));
            vel2=zeros(length(aux));
            Matrix=zeros(length(thisBB),length(thatBB));
            for i = 1 : length(thisBB) % Verificar todas as diferenças entre as BB do frame t e t-1
                for j = 1 : length(thatBB)
                    DiffX = abs(thisBB{i}(1) - thatBB{j}(1));
                    DiffY = abs(thisBB{i}(2) - thatBB{j}(2));
                    Diff= sqrt(DiffX*DiffX + DiffY*DiffY);
                    DiffX2 = abs(thisCC{i}(1) - thatCC{j}(1));
                    DiffY2 = abs(thisCC{i}(2) - thatCC{j}(2));
                    Diff2= sqrt(DiffX2*DiffX2 + DiffY2*DiffY2);
                    if ((Diff>4) && (Diff < 50)) || ((Diff2>4) && (Diff2 < 50)) %Caso a diferença seja significativa, assinalar na Matrix
                        Matrix(i,j) = 1;
                        vel(i)=Diff;
                        vel2(i)=Diff2;
                    else
                        Matrix(i,j) = 0;
                    end
                end
            end

%             Smatrix = cell(1, length(Matrix(:,1)));
%             MMatrix = transpose(Matrix);
%             Smatrix = cell(1,length(Matrix(:,1)));
%             for a = 1 : length(Matrix(:,1))
%                 pp = 1;
%                 for b = 1 : length(Matrix(1,:))
%                     if (Matrix(a,b) == 1)
%                         Smatrix{a} = b;
%                         pp = pp + 1;
%                     end
%                 end
%             end
%             %Tmatrix = cell(1, length(MMatrix(:,1)));
%             for a = 1 : length(MMatrix(:,1))
%                 pp = 1;
%                 for b = 1 : length(MMatrix(1,:))
%                     if (MMatrix(a,b) == 1)
%                         Tmatrix{a} = b;
%                         pp = pp + 1;
%                     end
%                 end
%             end
%             
%             if(length(thisBB)>length(thatBB))
%                 %split
%                'entrying'
%             end
%             if(length(thisBB)<length(thatBB))
%                var = 'exiting';
%              
%                 for index = 1 : length(Smatrix)
%                     if(length(Smatrix{index}) > 1)
%                       var='Merge'
%                     end
%                 end
%                 
%                  for index = 1 : length(Tmatrix)
%                     if(length(Tmatrix{index}) > 1)
%                       var='Split'
%                     end
%                  end
%                 
%            end
%             var = 0;
%             for b = 1 : length(Tmatrix)
%                 if (Tmatrix(b) == length(Matrix))
%                     var = 1;
%                 end
%             end
%             entering=0;
%             if(var ==0)
%                 if (Smatrix(length(Matrix)) isempty)
%                     entering=length(Matrix);
%                 end
%             end
% 
%             if(length(thatBB) > length(thisBB))
%                 for index = 1 : length(Smatrix)
%                     if isempty(Smatrix{index})
%                     elseif (((thatBB{Smatrix{index}}(3)*thatBB{Smatrix{index}}(4))*1.5 ) < (thisBB{index}(3)*thisBB{index}(4)))
%                         varsadas = ' MERGE'
%                         
%                     end
%                 end
%             end


            AuxMaster = 1;
            ArrayMaster=cell(1);
            for l = 1 : length(thisBB) % Tratar todas as regiões assinaladas na Matrix
                for c = 1 : length(thatBB)
                    if( Matrix(l,c) == 1) && (c==l)
%                         viscircles(thisCC{l}, 2,'edgecolor','green');
                        if(thisBB{l}(3) < thisBB{l}(4) && aux(l).Area < 3700 && aux(l).Area > 500 && ((vel(l) > 2 && vel(l) < 90)||(vel2(l) > 2 && vel2(l) < 90))) % Caso sejam pessoas
                            rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','g','LineWidth',2 )
                            text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Person','color','g');
                            ArrayMaster(AuxMaster) = thisBB(l);
                            AuxMaster = AuxMaster + 1;
                        elseif (aux(l).Area > 4800 && ((vel(l) > 2 && vel(l) < 90) || (vel2(l) > 2 && vel2(l) < 90)))  % Caso sejam carros
                            rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','r','LineWidth',2 )
                            text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Car','color','r');
                            ArrayMaster(AuxMaster) = thisBB(l);
                            AuxMaster = AuxMaster + 1;
                        else
                            rectangle('Position', [thisBB{l}(1),thisBB{l}(2),thisBB{l}(3),thisBB{l}(4)],'EdgeColor','b','LineWidth',2 )
                            text(thisBB{l}(1)-10,thisBB{l}(2)-20,'Other','color','b');
                        end
                        drawnow;
                    end
                end
            end 
            if( k ~= 170)
                areax=[];
                if ( length(PreMaster) > length(ArrayMaster)) % Possivel Merge
                   for inA = 1 : length(PreMaster)
                       if(inA ~= length(PreMaster))
                            areax(inA) = (PreMaster{inA}(3)*PreMaster{inA}(4)) + (PreMaster{inA+1}(3)*PreMaster{inA+1}(4));
                       end
                   end
                   if(length(areax)~=0)
                   for inB = 1 : length(ArrayMaster)
                       if(~isempty(ArrayMaster{inB}))
                       if ( (ArrayMaster{inB}(3)*ArrayMaster{inB}(4)) + 100 >= areax(inB))
                           text(150,30,'MERGE','color','r');
                           'MERGE'
                       end
                       end
                   end
                   end
                end
                areax=[];
                if ( length(PreMaster) < length(ArrayMaster)) % Possivel Split
                   for inA = 1 : length(ArrayMaster)
                       if(inA ~= length(ArrayMaster))
                            areax(inA) = (ArrayMaster{inA}(3)*ArrayMaster{inA}(4)) + (ArrayMaster{inA+1}(3)*ArrayMaster{inA+1}(4));
                       end
                   end
                   if(length(areax)~=0)
                   for inB = 1 : length(PreMaster)
                       if(~isempty(PreMaster{inB}))
                       if ( (PreMaster{inB}(3)*PreMaster{inB}(4)) + 100 >= areax(inB))
                           text(150,30,'SPLIT','color','r');
                           'SPLIT'
                       end
                       end
                   end
                   end
                end
            end
            thatBB = thisBB; % Preparar as BB do frame t para estarem presentes como t-1 no próximo frame
            thatCC = thisCC;
            PreMaster = ArrayMaster;
            clear aux;
        end
    end
    drawnow
end