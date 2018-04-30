% Generates the Negative Image
% cellDim: Collage one Cell dimesion
% collageGridDim: No. of cells in row and col of collage
function [ outputStatus ] = genNegImgFromCollagev3(collageDirPath,collageNum,cellDim,collageGridDim,negImgPerCollage,saveParentPath)
    outputStatus='Success';
    %% Init
    cellH=cellDim(1); cellW=cellDim(2);
    gridRow=collageGridDim(1); gridCol=collageGridDim(2);
    H=cellH*gridRow; W=cellW*gridCol;
    
    halfPatchH=cellH/2;halfPatchW=cellW/2;    
    hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
    wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
        
    halfCH=cellH/2;
    halfCW=cellW/2;    
    
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
    
    %% Generate from Collage        
    collagePath=strcat(collageDirPath,'/',num2str(collageNum),'.mat');
    struct=load(collagePath);
    collage=struct.img;
    %collage=collage(1:cellH+2,:); %debug   
    stride=5; offset=30; imgNum=0;
    %hEndIdx=min(hEndIdx,hStartIdx + (stride*333));
    for i=hStartIdx:stride:hEndIdx  
        fprintf('Procession %d/%d..\n',i,hEndIdx);
        for j=wStartIdx:stride:wEndIdx           
            cx=i;cy=j;
            quotX= floor(cx/halfCH);remX= mod(cx,halfCH);
            quotY= floor(cy/halfCW);remY= mod(cy,halfCW);
            % mod(quotX,2) ~=0: define center of true position
            if (mod(quotX,2) ~=0 && remX<offset) && (mod(quotY,2) ~=0 && remY< offset)
                continue;
            end
            % Finding Patch Coordinate
            if evenH
                x1=cx-floor(halfCH);x2=cx + floor(halfCH) - 1;
            else
                x1=cx-floor(halfCH);x2=cx + floor(halfCH);
            end
            if evenW
                y1=cy-floor(halfCW);y2=cy + floor(halfCW) - 1;
            else
                y1=cy-floor(halfCW);y2=cy + floor(halfCW);
            end
            %fprintf('cx:%d cy:%d x1:%d x2:%d y1:%d y2:%d\n',cx,cy,x1,x2,y1,y2);
            img=collage(x1:x2,y1:y2);
            dim=size(img);
            imgNum=imgNum+1;
            if (dim(1) == cellH && dim(2) == cellW)
                img=img/max(img(:));                
                imwrite(im2double(img),strcat(savedImgDir,'/',num2str(imgNum),'.jpg'));
                save(strcat(savedRawImgDir,'/',num2str(imgNum),'.mat'),'img');
            else
                fprintf('Error: Dim of Img didnt match. Please verfy code\n');
                outputStatus='Error.';
            end
        end
        fprintf('\n\n #image Generated Till now:%d\n',imgNum);
    end
    

%%
    fprintf('\n\n***** Total image Generated:%d\n',imgNum);
    outputStatus =strcat(outputStatus,' Verify your result at path:',savedImgDir);
end

