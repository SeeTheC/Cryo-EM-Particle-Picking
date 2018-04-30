% Finds the Score for each overlapping patch: Scaled Model architecture
function [ outCell ] = predictScaledModelOnCollageCPUThread(collage,patchDim,modelType,dirPath,modelpath,thread)
    
    %% Init
    [H,W]=size(collage);    
    patchH=patchDim(1);patchW=patchDim(2);    
    halfPatchH=patchH/2;halfPatchW=patchW/2;
   
    hStartIdx=ceil(halfPatchH);
    wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
    collageCell=cell(thread,1);
    outCell=cell(thread,1);
    threadImgHeight= floor(H/thread);
    
    for i=1:thread
        offset=(i-1)*threadImgHeight+1;
        x1=offset-floor(halfPatchH);
        x2=offset+threadImgHeight-1+floor(halfPatchH);
        if x1 < 1
            x1=1;
        end        
        if x2 > H
            x2=H;
        end
        collageCell{i}=collage(x1:x2,:);
        outCell{i}=zeros(x2-x1+1,W);
    end
    fprintf('*Init ...\n');
    
    %% INIT Model Specific features
    if modelType==ModelType.CompactSVM
        svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
        svm_pcamu=load(strcat(dirPath,'/data_mean.txt'));  
        struct=load(strcat(modelpath,'/compactSVMModel.mat'));
        trainedModel=struct.compactSVMModel;        
    end
    fprintf('Init Done. Processing data..');   
    %% Ovelapping Patch    
    parfor t=1:thread 
        cc=collageCell{t};
        outImg=outCell{t};  
        cellH=size(cc,1);
        hEndIdx=cellH-floor(halfPatchH);
        fprintf('Starting thread %d Start:%d End:%d ...\n',t,hStartIdx,hEndIdx);
        for r= hStartIdx:hEndIdx             
            for c=wStartIdx:wEndIdx
                fprintf('Thread: %d Row:%d Col:%d\n',t,r,c);
                cx=r;cy=c;
                [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
                patch=cc(x1:x2,y1:y2);
                % Extacting Feature
                if modelType==ModelType.CompactSVM
                    feature = reduceDimByPCA(svm_pcaCoeff,svm_pcamu,patch);
                end
                [~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
                outImg(r,c)=positiveScore;
            end
        end
        outCell{t}=outImg; 
        fprintf('Completed thread %d. R: %d...\n',t,r);
    end
    %%
end


