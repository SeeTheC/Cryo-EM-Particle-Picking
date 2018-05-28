% Finds the Score for each overlapping patch 
function [ outImg ] = predictScaledModelL1Collage(collage,patchDim,modelType,dirPath,modelpath)
    
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
        svm_pcamu=load(strcat(dirPath,'/data_mean.txt'));        
        struct=load(strcat(modelpath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;
    elseif modelType==ModelType.RandomForest
        rf_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        rf_pcamu=dlmread(strcat(dirPath,'/data_mean.txt'));
        struct=load(strcat(modelpath,'/rfModel.mat'));
        trainedModel=struct.rfModel;
    elseif modelType==ModelType.DecisionTree
        dt_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        dt_pcamu=dlmread(strcat(dirPath,'/data_mean.txt'));
        struct=load(strcat(modelpath,'/dtModel.mat'));
        trainedModel=struct.dtModel;
    end
    fprintf('Init Done. Processing data..');
    %% Ovelapping Patch
    for r= hStartIdx:hEndIdx             
        for c=wStartIdx:wEndIdx
            fprintf('Row:%d Col:%d\n',r,c);
            cx=r;cy=c;
            [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
            patch=collage(x1:x2,y1:y2);
           
            % Extacting Feature
            if modelType==ModelType.CompactSVM
                feature = reduceDimByPCA(svm_pcaCoeff,svm_pcamu,patch);
            elseif modelType==ModelType.RandomForest
                feature = reduceDimByPCA(rf_pcaCoeff,rf_pcamu,patch);
            elseif modelType==ModelType.DecisionTree
                feature = reduceDimByPCA(dt_pcaCoeff,dt_pcamu,patch);
            end
            [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
            outImg(r,c)=positiveScore;
        end
    end


    %%
end


