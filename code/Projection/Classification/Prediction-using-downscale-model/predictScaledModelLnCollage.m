% Level2 Scale Model Prediction
% I.e Using location not at every location
function [outImg,outLoc] = predictScaledModelLnCollage(collage,patchDim,location,modelType,dirPath,modelpath)
    
    %% Init
    [H,W]=size(collage);    
    patchH=patchDim(1);patchW=patchDim(2);    
    noOfLoc=size(location,1);
    outLoc=zeros(noOfLoc,3);
    fprintf('Init ...\n');
    outImg=zeros(H,W);
    %% INIT Model Specific features
    if modelType==ModelType.CompactSVM
        svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        svm_pcamu=load(strcat(dirPath,'/data_mean.txt'));        
        struct=load(strcat(modelpath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;        
    end
    fprintf('Init Done. Processing data..\n');
    %% ON SPECIFIC loacation Patch
    tic
    for i= 1:noOfLoc         
        cx=location(i,1);cy=location(i,2);
        [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);        
        fprintf('%d)\t#Loc:%d\tRow:%d\tCol:%d\n',i,noOfLoc,cx,cy);       
        if x1<1 || x2>H || y1<1 || y2>W 
            continue;
        end
        patch=collage(x1:x2,y1:y2);
        % Extacting Feature
        if modelType==ModelType.CompactSVM
            feature = reduceDimByPCA(svm_pcaCoeff,svm_pcamu,patch);
        end
        [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
        outLoc(i,:)=[cx,cy,positiveScore];    
        outImg(cx,cy)=positiveScore;
    end
    toc
    fprintf('Done.\n');

    %%
end


