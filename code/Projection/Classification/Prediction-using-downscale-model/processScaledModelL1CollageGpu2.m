function [ outCell ] = processScaledModelL1CollageGpu2(collage,patchDim,modelType,dirPath,modelpath)
    %% INIT 1.0
    gpu=1;
    [H,W]=size(collage); 
    patchH=patchDim(1);patchW=patchDim(2);    
    halfPatchH=patchH/2;       
    %% Divinding collages Parts 
    % Divinding collages Parts into different parts. Because RAM & GPU
    % memory will not sufficient to process the full collage at a time.    
    noOfParts=10;    
    partImgHeight= floor(H/noOfParts);     
    collageCell=cell(noOfParts,1);    
    fprintf('\n***# of parts: %d partImgHeight:%d patchH:%d H:%d\n', noOfParts,partImgHeight,patchH,H);
 
    if partImgHeight < halfPatchH
        fprintf('\n*** ERROR: EACH PART HEIGHT IS LESS THAN PATCH HEIGHT. SET noOfParts Value Correctly');
        return;
    end
    for i=1:noOfParts
        offset=(i-1)*partImgHeight;
        x1=offset-floor(halfPatchH)+1;
        x2=offset+partImgHeight-1+floor(halfPatchH);
        if x1 < 1
            x1=1;
        end        
        if x2 > H
            x2=H;
        end
        collageCell{i}=collage(x1:x2,:);
        %outCell{i}=zeros(x2-x1+1,W);
    end
    %% Predict
    [outCell]=predictUsingGPU(collageCell,patchDim,modelType,dirPath,modelpath,gpu);            
end

function [outCell]=predictUsingGPU(collageCell,patchDim,modelType,dirPath,modelpath,gpu)    
    %% Init 1.0
    patchH=patchDim(1);patchW=patchDim(2);        
    noOfParts=size(collageCell,1);
    outCell=cell(noOfParts,1);
    %% SVM    
    if modelType==ModelType.CompactSVM
        fprintf('Loading PCA coefficent....');
        svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        svm_pcamu=load(strcat(dirPath,'/data_mean.txt'));   
        struct=load(strcat(modelpath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;  
        modelType=ModelType.CompactSVM;
        fprintf('Done ..\n');
    elseif modelType==ModelType.RandomForest
        fprintf('Loading PCA coefficent....');
        rf_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        rf_pcamu=load(strcat(dirPath,'/data_mean.txt'));
        struct=load(strcat(modelpath,'/rfModel.mat'));
        trainedModel=struct.rfModel;
        modelType=ModelType.RandomForest;
        fprintf('Done ..\n');
    elseif modelType==ModelType.DecisionTree
        fprintf('Loading PCA coefficent....');
        dt_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        dt_pcamu=load(strcat(dirPath,'/data_mean.txt'));
        struct=load(strcat(modelpath,'/dtModel.mat'));
        trainedModel=struct.dtModel;
        modelType=ModelType.DecisionTree;
        fprintf('Done ..\n');
    end
    %% Gpu
    if gpu ==1 
        fprintf('Gpu: init...');
        if modelType==ModelType.CompactSVM    
            svm_pcaCoeff=gpuArray(svm_pcaCoeff);
            svm_pcamu=gpuArray(svm_pcamu);
        elseif modelType==ModelType.RandomForest 
            rf_pcaCoeff=gpuArray(rf_pcaCoeff);
            rf_pcamu=gpuArray(rf_pcamu);
        elseif modelType==ModelType.DecisionTree 
            dt_pcaCoeff=gpuArray(dt_pcaCoeff);
            dt_pcamu=gpuArray(dt_pcamu);
        end
        for section=1:noOfParts
            collageCell{section}=gpuArray(collageCell{section});
        end
        fprintf('Done \n');    
    end
    %% Per Patch methods
    function [ feature ] = perPatchMethod(cellCol)   
         vector=cellCol{1}; 
         % Extacting Feature
        if modelType==ModelType.CompactSVM
            feature=bsxfun(@minus,vector,svm_pcamu)*svm_pcaCoeff;
        elseif modelType==ModelType.RandomForest
            feature=bsxfun(@minus,vector,rf_pcamu)*rf_pcaCoeff;
        elseif modelType==ModelType.DecisionTree
            feature=bsxfun(@minus,vector,dt_pcamu)*dt_pcaCoeff;
        end
         clear vector;
         feature=gather(feature);
         %[~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
         %num=positiveScore;     
    end
    
    %% Process on each part of collage
    for section=1:noOfParts
        fprintf('............[%d/%d].........\n',section,noOfParts);
        [H,W]=size(collageCell{section});      
        patchRegion=[H-patchH+1,W-patchW+1];     
        fprintf('\n patchRegion:%d H:%d\n',patchRegion(1),H); 
        %% Creating Cell Array array
        tic
        fprintf('Creating Cell Array array...\n');
        colmat=im2col(collageCell{section},patchDim);
        fprintf('Dim of colmat:%dx%d',size(colmat,1),size(colmat,2));
        dim=ones(1,size(colmat,2));
        cellColl = mat2cell(colmat',dim);
        clear colmat;
        fprintf('Done...\n');
        toc
        %% Processing
        tic
        fprintf('Processing...');
        b=arrayfun(@perPatchMethod,cellColl,'UniformOutput',false);
        fprintf('Done...\n');
        toc
        fprintf('Finding Prediction...');
        tic
        n=size(b,1);
        output=zeros(size(cellColl,2),1);  
        clear cellColl;   
        parfor i=1:n    
            feature=b{i};
            [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
            output(i)=positiveScore; 
        end
        toc
        %%  Correcting the dimension of o/p
        fprintf(' Correcting the dimension of o/p/ \n');
        outImg=reshape(output,patchRegion(1),patchRegion(2));
        if mod(H,2)==0 % even
            outImg = padarray(outImg,[floor((H-patchRegion(1))/2), 0],0,'pre');
            outImg = padarray(outImg,[ceil((H-patchRegion(1))/2), 0],0,'post');
        else % odd
            %outImg = padarray(outImg,[(H-patchRegion(1))/2, 0],0,'both'); 
            outImg = padarray(outImg,[floor((H-patchRegion(1))/2), 0],0,'pre');
            outImg = padarray(outImg,[ceil((H-patchRegion(1))/2), 0],0,'post');
        end   
        if mod(W,2)==0 % even
            outImg = padarray(outImg,[0, floor((W-patchRegion(2))/2)],0,'pre');
            outImg = padarray(outImg,[0, ceil((W-patchRegion(2))/2)],0,'post');
        else % odd
            %outImg = padarray(outImg,[0, (W-patchRegion(2))/2],0,'both');     
            outImg = padarray(outImg,[0, floor((W-patchRegion(2))/2)],0,'pre');
            outImg = padarray(outImg,[0, ceil((W-patchRegion(2))/2)],0,'post');
        end
        outCell{section}=outImg;
   end        

end

