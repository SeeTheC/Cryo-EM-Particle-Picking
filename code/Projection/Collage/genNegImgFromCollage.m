% Generates the Negative Image
% cellDim: Collage one Cell dimesion
% collageGridDim: No. of cells in row and col of collage
function [ outputStatus ] = genNegImgFromCollage(collageDirPath,cellDim,collageGridDim,negImgPerCollage,saveParentPath)
    outputStatus='Success';
    %% Init
    cellH=cellDim(1); cellW=cellDim(2);
    gridRow=collageGridDim(1); gridCol=collageGridDim(2);
    H=cellH*gridRow; W=cellW*gridCol;
        
    centerShiftHOffest=floor(cellH/8);
    centerShiftWOffest=floor(cellW/8);
    halfCH=cellH/2;
    halfCW=cellW/2;
    
    % Fetching filename
    fileNameList=getDirFilesName(collageDirPath);
    noOfCollage=size(fileNameList,2);

    if mod(cellH,2) ==0
        evenH=1;
    else
        evenH=0;
    end    
    if mod(cellW,2) ==0
        evenW=1;
    else
        evenW=0;
    end    
    %%  Create Dir
    savepath=strcat(saveParentPath,'/NegImg_',datestr(now,'dd-mm-yyyy HH:MM:SS')); 
    savedImgDir=strcat(savepath,'/img'); 
    savedRawImgDir=strcat(savepath,'/raw_img');
    mkdir(savepath);
    mkdir(savedImgDir);
    mkdir(savedRawImgDir);
    
    %% Generate Collage    
    for c=1:noOfCollage
        fprintf('Colage: %d\n',c);
        name=fileNameList{c};        
        collagePath=strcat(collageDirPath,'/',num2str(c),'.mat');
        struct=load(collagePath);
        collage=struct.img;
        for i=1:negImgPerCollage
            cx=randi([ceil(halfCH)+1,H-ceil(halfCH)]);
            cy=randi([ceil(halfCW)+1,W-ceil(halfCW)]);
            quotX= cx/halfCH;remX= mod(cx,halfCH);
            quotY= cy/halfCW;remY= mod(cy,halfCW);
            
            % means: pt should not line on the center of cell +- offset
            if ( (remX==0 && remY && mod(quotX,2) ~=0 && mod(quotY,2) ~=0 ) ...
                   || remX > cellH-centerShiftHOffest ...
                   || remY > cellW-centerShiftWOffest )
               
                if(cx + centerShiftHOffest > H - ceil(halfCH))
                    cx=cx-centerShiftHOffest;
                else
                    cx=cx+centerShiftHOffest;   
                end
                if(cy + centerShiftWOffest > W - ceil(halfCW))
                    cy=cy-centerShiftWOffest;
                else
                    cy=cy+centerShiftWOffest;   
                end
            end%end if
            %imgPath=strcat(dataPath{dir},'/',num2str(imgNum),'.mat');
            %struct=load(imgPath);
            
            % Finding Patch Coordinate
            if evenH
                x1=ceil(cx)-floor(halfCH);x2=ceil(cx) + floor(halfCH) - 1;
            else
                x1=ceil(cx)-floor(halfCH);x2=ceil(cx) + floor(halfCH);
            end
            if evenW
                y1=ceil(cy)-floor(halfCW);y2=ceil(cy) + floor(halfCW) - 1;
            else
                y1=ceil(cy)-floor(halfCW);y2=ceil(cy) + floor(halfCW);
            end
            img=collage(x1:x2,y1:y2);
            dim=size(img);
            imgNum=negImgPerCollage*(c-1) + i;
            if (dim(1) == cellH && dim(2) == cellW)
                img=img/max(img(:));
                imwrite(im2double(img),strcat(savedImgDir,'/',num2str(imgNum),'.jpg'));
                save(strcat(savedRawImgDir,'/',num2str(imgNum),'.mat'),'img');
            else
                fprintf('Error: Dim of Img didnt match. Please verfy code\n');
                outputStatus='Error.';
            end
        end    
    end


%%
    outputStatus =strcat(outputStatus,' Verify your result at path:',savedImgDir);
end

