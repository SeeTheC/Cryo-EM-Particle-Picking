function [ outImg,outLoc ] = processScaledModelL2CollageGpu2(collage,patchDim,predLocation,modelType,dirPath,modelpath)
    %% INIT 1.0
    gpu=1;            
    noOflocation=size(predLocation,1);
    %% Cropping the image at mutliple location
    % Divinding collages Parts into different parts. Because RAM & GPU
    % memory will not sufficient to process the full collage at a time.    
    procParallelPatch=1000;
    noOfParts=floor(noOflocation/procParallelPatch);       
    [locationCell]=divideInSection(predLocation,collage,noOfParts);
    %% Predict
    [outImg,outLoc]=predictUsingGPU(collage,locationCell,patchDim,modelType,dirPath,modelpath,gpu);            

end
function [outImg,outputLoc]=predictUsingGPU(collage,locationCell,patchDim,modelType,dirPath,modelpath,gpu)    
    %% Init 1.0
    [H,W]=size(collage);     
    noOfParts=size(locationCell,1);
    outImg=zeros(H,W);
    outputLoc=[];
    %% SVM    
    if modelType==ModelType.CompactSVM
        fprintf('Loading PCA coefficent....');
        svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        svm_pcamu=load(strcat(dirPath,'/data_mean.txt'));   
        struct=load(strcat(modelpath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;  
        modelType=ModelType.CompactSVM;
        fprintf('Done ..\n');
    end
    %% Gpu
    if gpu ==1 
        fprintf('Gpu: init...');
        if modelType==ModelType.CompactSVM    
            svm_pcaCoeff=gpuArray(svm_pcaCoeff);
            svm_pcamu=gpuArray(svm_pcamu);
        end
        collage=gpuArray(collage);
        fprintf('Done \n');    
    end
    %% Per Patch methods
    function [ feature ] = perPatchMethod(cellCol)   
         vector=cellCol{1};   
         feature=bsxfun(@minus,vector,svm_pcamu)*svm_pcaCoeff;  
         clear vector;
         feature=gather(feature);
    end
    
    %% Process on each part of collage
    fprintf('Processing...\n')
    for section=1:noOfParts
        fprintf('............[%d/%d].........\n',section,noOfParts);
        location=locationCell{section};    
        %% Creating Cell Array array
        tic
        fprintf('Creating Cell Array array...\n');
        [cellColl,location]=getCroppedImgMtx(collage,location,patchDim);
        fprintf('No Of Location:%d \nEach of Dim:%dx%d',size(cellColl,2),patchDim(1),patchDim(2));
        fprintf('Done...\n');
        toc
        if (size(cellColl,1)==0)
            fprintf('[Info] No Correct Patch to process');
            continue;
        end
        %% Processing
        tic
        fprintf('Processing...');
        b=arrayfun(@perPatchMethod,cellColl','UniformOutput',false);
        fprintf('Done...\n');
        toc
        fprintf('Finding Prediction...');
        tic
        n=size(b,1);
        output=zeros(n,1);  
        clear cellColl;   
        parfor i=1:n               
            feature=b{i};
            [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);            
            output(i)=positiveScore;            
        end
        fprintf('Done.\n')
        toc        
        %%  Marking score on Image
        fprintf('Marking Score on Image...');
        resLoc=zeros(n,3);
        for i=1:n
            x=location(i,1);y=location(i,2);
            outImg(x,y)=output(i);
            resLoc(i,:)=[x,y,output(i)];
        end
        outputLoc=vertcat(outputLoc,resLoc);
        fprintf('Done.\n')
   end        

end


%% DivideInSection

% Divide location in Section for memory 
function [croppedLocCell]=divideInSection(location,collage,noOfParts)
    noOfLocation=size(location,1);
    sectionSize=floor(noOfLocation/noOfParts);    
    croppedLocCell=cell(noOfParts,1);
    for i=1:noOfParts
        offset=(i-1)*sectionSize;
        x1=offset;
        x2=offset+sectionSize;
        if x1 < 1
            x1=1;
        end        
        if x2 > noOfLocation
            x2=noOfLocation;
        end
        croppedLocCell{i}=location(x1:x2,:);
    end
end

% Returns the cropped patch at passes "location" point as cell
function [cropCol,resLoc]=getCroppedImgMtx(collage,location,patchDim)
    [H,W]=size(collage); 
    patchH=patchDim(1);patchW=patchDim(2);   
    noOfLocation=size(location,1);
    cropCol={}; resLoc=[];noOfPatch=1;
    noOfPatch=1;
    for i=1:noOfLocation
      cx=location(i,1);cy=location(i,2);
      [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
      if (x1<=0 || x2>H || y1 <=0 || y2 > W)
        continue;
      end
      patch=collage(x1:x2,y1:y2);
      cropCol{noOfPatch} = reshape(patch,1,patchH*patchW); 
      resLoc=vertcat(resLoc,[cx,cy]);
      noOfPatch=noOfPatch+1;
    end
end