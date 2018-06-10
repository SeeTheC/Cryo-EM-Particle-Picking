% Finds the Score for each overlapping patch 
function [ outImg ] = predictOnCollage(collage,patchDim,modelType,dirPath)
    
    %% Init
    [H,W]=size(collage);
    outImg=zeros(H,W);
    patchH=patchDim(1);patchW=patchDim(2);    
    halfPatchH=patchH/2;halfPatchW=patchW/2;
   
    hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
    wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
    fprintf('Init ...\n');
    %% INIT Model Specific features
    if modelType==ModelType.CompactSVM
        svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        svm_pcamu=dlmread(strcat(dirPath,'/data_mean.txt'));
        svm_pcamu=svm_pcamu';
        struct=load(strcat(dirPath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;        
    end
    fprintf('Init Done. Processing data..');
    %% Ovelapping Patch
    parfor r= hStartIdx:hEndIdx             
        for c=wStartIdx:wEndIdx
            fprintf('Row:%d Col:%d\n',r,c);
            cx=r;cy=c;
            [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
            %patch=collage(x1:x2,y1:y2);
           
            % Extacting Feature
            if modelType==ModelType.CompactSVM
                feature = reduceDimByPCA(svm_pcaCoeff,svm_pcamu,collage,[x1,x2,y1,y2]);
            end
            [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
            outImg(r,c)=positiveScore;
        end
    end


    %%
end

function [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim)

    patchH=patchDim(1);patchW=patchDim(2);   
    halfPatchH=patchH/2;halfPatchW=patchW/2;
    ispatchHOdd= mod(patchH,2); ispatchWOdd= mod(patchW,2);
    if ~ispatchHOdd
        x1=cx -floor(halfPatchH) + 1; x2 = cx + floor(halfPatchH);
    else
        x1=cx -floor(halfPatchH); x2 = cx + floor(halfPatchH);   
    end

    if ~ispatchWOdd
        y1=cy -floor(halfPatchW) + 1; y2 = cy + floor(halfPatchW);
    else
        y1=cy -floor(halfPatchW); y2 = cy + floor(halfPatchW);   
    end
      
end
