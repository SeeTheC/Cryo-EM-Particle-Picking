%% Run on Collage
% Param
%   Scale: [1,2,4] means downscale image by 1, half, one fourth...
% sample call: 
% simple: mainScaleModelOnCollage(0,[333,333],[1,2,4],ModelType.DecisionTree,false,false)
% multi-cpu: mainScaleModelOnCollage(0,[333,333],[1,2,4],ModelType.RandomForest,true,false)
%            :Set thread value in code
% gpu: mainScaleModelOnCollage(1,[333,333],[1,2,4],ModelType.RandomForest,false,true)
%     : Set noOfParts value in code depending on GPU memory

function [ status ] =  mainScaleModelOnCollage(server,imgdim,scale,modelType,isThreaded,gpu)
    status='failed';
    %% Init    
    if server
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    else
        basepath='/home/ayush/mtech/subj4/aip/project';  
    end    
    fprintf('----------------[Config]-------------------\n')
    fprintf('Config: IsThread: %d\n',isThreaded);
    fprintf('Config: Gpu:%d \n',gpu);
    collageNum='1';
    % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE        
    
    %basepath=strcat(basepath,'/_data-proj-5689v.20'); 
    basepath=strcat(basepath,'/_data-Y,Zv.10','/Noisy_downscale500');         
    %basepath=strcat(basepath,'/_data-proj-2211','v.20');        %imsize: [98,98] 
    %basepath=strcat(basepath,'/_data-proj-2211','v.20','/Noisy_downscale500');  %imsize: [178,178]                  
    %basepath=strcat(basepath,'/_data-proj-5689','v.20');    %imsize: [278,278] 
    %basepath=strcat(basepath,'/_data-proj-5689','v.20','/Noisy_downscale500'); %imsize: [278,278];        

    testPath=strcat(basepath,'/test');
    testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/',collageNum,'.mat');
    mt='';
    if modelType==ModelType.CompactSVM   
		mt='svm'; 
    elseif modelType==ModelType.RandomForest
		mt='ramdomForest';
    elseif modelType==ModelType.DecisionTree
		mt='decisionTree';
    end
    savepath= strcat(testPath,'/collage1_6x6','/processed_img/',mt,'/',collageNum);    
    struct=load(testCollagePath);
    collage=struct.img;
    fprintf('Config: Collage:%s.mat \n',collageNum);
    minProbabiltyScore=0.4;
    fprintf('Config: Min. Prob Score:%f \n',minProbabiltyScore);
    fprintf('-------------------------------------------------\n')
    
    %isThreaded=0
    %gpu=1
    %% Perdict    
    model='/model_1-2-4';
    basepath=strcat(basepath,model);savepath=strcat(savepath,model);
    noOfScale=numel(scale);
    for i=noOfScale:-1:1
        fprintf('----------------[Processing Model-%d (decending order)]-------------------\n',i);
        modelnumber=i;downscale=scale(i);  
        if i==noOfScale
            fprintf('Checking for Processed model-%d, if exist or not?\n',i);            
            file=strcat(savepath,'/model-',num2str(i),'/',collageNum,'.mat');
            if  exist(file,'file')
                fprintf('-->Found :).\n Loading previous computed files..\n');                
                prevStageImg=load(file);
                prevStageImg=prevStageImg.outImg;
                fprintf('Done.\n');
            else
                % File does not exist.
                fprintf('-->Not-Found :');
                [prevStageImg]=predictOnFullCollage(server,collage,collageNum,imgdim,modelnumber,downscale,basepath,savepath,modelType,isThreaded,gpu);    
            end
            [location,particleCount] = findProbableLoc(prevStageImg,minProbabiltyScore); 
            fprintf('# of particles found at stage%d: %d\n',i,particleCount);

        else
            location=coordUpscaleAndAddPt(prevLoc(:,[1,2]),scale(i+1)/scale(i),true);
            [prevStageImg,outLoc]=predictOnSpecLocCollage(server,collage,collageNum,imgdim,location,modelnumber,downscale,basepath,savepath,modelType,isThreaded,gpu);                       
            location=[];
            if size(outLoc,1) >0
                location=outLoc(outLoc(:,3)>minProbabiltyScore,:);
            end
                
        end                
        prevLoc=location;
    end
    outImg=prevStageImg;
    status='completed';
end

%% PredictOnSpecLocCollage

% It will find probabilty score at "SPECIFIC LOCATION" pixel of collage 
function [outImg,outLoc]=predictOnSpecLocCollage(server,collage,collageNum,imgdim,location,modelnumber,downscale,basepath,savepath,modelType,isThreaded,gpu)
    % patchH == cellH of collage and patchW == cellW of collage      
    patchH=ceil(imgdim(1)/downscale);patchW=ceil(imgdim(2)/downscale);
    %collage=collage(1:patchH,:);
    collage=imresize(collage,1/downscale);        
    %% Show OriginalCollage
    if ~server
        figure('name','Original Collage');
        imshow(collage,[]);
    end
    %% 1.0 SVMv2.0 - Process college
    tic
    model=strcat('/model-',num2str(modelnumber));
    if modelType==ModelType.CompactSVM
        svmModel=strcat('/svm',model);  
        modelpath=  strcat(basepath,svmModel); 
    elseif modelType==ModelType.RandomForest
        rfModel=strcat('/rf',model);
        modelpath=  strcat(basepath,rfModel);
    elseif modelType==ModelType.DecisionTree
        dtModel=strcat('/dt',model);
        modelpath=  strcat(basepath,dtModel);
    end
    workingDirPath=  strcat(basepath,'/pca_data/train/',model);
    %modelpath=  strcat(basepath,svmModel);   
    if (~isThreaded && ~gpu)
        fprintf('Processing without thread...');
        [outImg,outLoc] = predictScaledModelLnCollage(collage,[patchH,patchW],location,modelType,workingDirPath,modelpath);

    elseif false && isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        % TO BE WRIITEN (IF REQUIRED)
    elseif gpu
       fprintf('Processing with Gpu.\n');  
       [outImg,outLoc]  = processScaledModelLnCollageGpu2(collage,[patchH,patchW],location,modelType,workingDirPath,modelpath); 
    end
    fprintf('Done Processing..\n');
    toc
    %% Save
    if ~server
        figure('name','Predicted Collage');
        imshow(outImg,[]);
    end
    savepath=strcat(savepath,model);
    saveCollageImg(outImg,savepath,collageNum);

end

%% SaveImg

% Saves the image at specified path
function saveCollageImg(outImg,savepath,collageNum)
    mkdir(savepath);
    tmpImg=outImg-min(outImg(:));tmpImg=tmpImg./max(tmpImg(:));
    imwrite(tmpImg,strcat(savepath,'/',collageNum,'.jpg'));
    save(strcat(savepath,'/',collageNum,'.mat'),'outImg');
end


%% PredictOnFullCollage

% It will find probabilty score at every pixel of collage using the
% overlapping patches
function outImg=predictOnFullCollage(server,collage,collageNum,imgdim,modelnumber,downscale,basepath,savepath,modelType,isThreaded,gpu)

    % patchH == cellH of collage and patchW == cellW of collage      
    patchH=ceil(imgdim(1)/downscale);patchW=ceil(imgdim(2)/downscale);
    %collage=collage(1:patchH,:);
    collage=imresize(collage,1/downscale);    
    collageSize=size(collage);
    %% Show OriginalCollage
    if ~server
        figure('name','Original Collage');
        imshow(collage,[]);
    end
    %% 1.0 SVMv2.0 - Process college
    tic
    
    model=strcat('/model-',num2str(modelnumber));
    if modelType==ModelType.CompactSVM
        svmModel=strcat('/svm',model);  
        modelpath=strcat(basepath,svmModel); 
    elseif modelType==ModelType.RandomForest
        rfModel=strcat('/rf',model);
        modelpath=  strcat(basepath,rfModel); 
    elseif modelType==ModelType.DecisionTree
        dtModel=strcat('/dt',model);
        modelpath=  strcat(basepath,dtModel); 
    end
    workingDirPath=  strcat(basepath,'/pca_data/train',model);
    if ~isThreaded && ~gpu
        fprintf('Processing without thread...');
        [outImg] = predictScaledModelL1Collage(collage,[patchH,patchW],modelType,workingDirPath,modelpath);
        
    elseif isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        thread=10;
        delete(gcp('nocreate'));
        parpool(thread)
        [outCell] = predictScaledModelL1CollageCPUThread(collage,[patchH,patchW],modelType,workingDirPath,modelpath,thread);
        [outImg]=mergeParallelCollage(outCell,[patchH,patchW],collageSize);    
        
    elseif gpu
        fprintf('Processing with Gpu.');
        [outCell] = processScaledModelL1CollageGpu2(collage,[patchH,patchW],modelType,workingDirPath,modelpath);        
        [outImg]=mergeParallelCollage(outCell,[patchH,patchW],collageSize);    
    end
    fprintf('Done Processing..\n');
    toc
    %% Save
    if ~server
        figure('name','Predicted Collage');
        imshow(outImg,[]);
    end
    savepath=strcat(savepath,model);
    mkdir(savepath);
    tmpImg=outImg-min(outImg(:));tmpImg=tmpImg./max(tmpImg(:));
    imwrite(tmpImg,strcat(savepath,'/',collageNum,'.jpg'));
    save(strcat(savepath,'/',collageNum,'.mat'),'outImg');
end

%% MergeParallelCollage

% In Thread mode: merge the differnent parts of collage
%  cellDim= [333,333] 
function [mergedImg]=mergeParallelCollage(imgCell,cellDim,orgCollageDim)
    cellH=cellDim(1); cellW=cellDim(2);
    H=orgCollageDim(1); W=orgCollageDim(2);   
    outImg=zeros(H,W);
    thread=size(imgCell,1);
    threadImgHeight= floor(H/thread);
    halfPatchH=cellH/2;    
    for i=1:thread
        offset=(i-1)*threadImgHeight;
        x1=offset-floor(halfPatchH)+1;
        x2=offset+threadImgHeight-1+floor(halfPatchH);
        if x1 <1
            x1=1;
        end
        if x2 > H
            x2=H;
        end    
        img=imgCell{i};
        outImg(x1:x2,:)=outImg(x1:x2,:)+img;
    end
    mergedImg=outImg;
end
