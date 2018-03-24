%% Run on Collage
% Param
%   Scale: [1,2,4] means downscale image by 1, half, one fourth...
% sample call: 
% simple: mainScaleModelOnCollage(0,[333,333],[1,2,4],false,false)
% multi-cpu: mainScaleModelOnCollage(0,[333,333],[1,2,4],true,false)
%            :Set thread value in code
% gpu: mainScaleModelOnCollage(0,[333,333],[1,2,4],false,true)
%     : Set noOfParts value in code depending on GPU memory

function [ status ] =  mainScaleModelOnCollage(server,imgdim,scale,isThreaded,gpu)
    status='failed';
    %% Init    
    if server
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
    end    
    fprintf('----------------[Config]-------------------\n')
    fprintf('Config: IsThread: %d\n',isThreaded);
    fprintf('Config: Gpu:%d \n',gpu);
    collageNum='1';
    % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE        
    basepath=strcat(basepath,'/_data-Y,Z','v.10');
    testPath=strcat(basepath,'/test');
    testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/',collageNum,'.mat');
    savepath= strcat(testPath,'/collage1_6x6','/processed_img/',collageNum);    
    struct=load(testCollagePath);
    collage=struct.img;
    fprintf('Config: Collage:%s.mat \n',collageNum);
    minProbabiltyScore=0.8;
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
            if false && exist(file,'file')
                fprintf('-->Found :).\n Loading previous computed files..\n');                
                prevStageImg=load(file);
                prevStageImg=prevStageImg.outImg;
                fprintf('Done.\n');
            else
                % File does not exist.
                [prevStageImg]=predictOnFullCollage(server,collage,collageNum,imgdim,modelnumber,downscale,basepath,savepath,isThreaded,gpu);    
            end
            [location,particleCount] = findProbableLoc(prevStageImg,minProbabiltyScore); 
            fprintf('# of particles found at stage%d: %d\n',i,particleCount);

        else
            location=coordUpscaleAndAddPt(prevLoc(:,[1,2]),scale(i+1)/scale(i),true);
            [prevStageImg,outLoc]=predictOnSpecLocCollage(server,collage,collageNum,imgdim,location,modelnumber,downscale,basepath,savepath,isThreaded,gpu);           
            location=outLoc(outLoc(:,3)>minProbabiltyScore,:);
        end                
        prevLoc=location;
    end
    outImg=prevStageImg;
    status='completed';
end

%% PredictOnSpecLocCollage

% It will find probabilty score at "SPECIFIC LOCATION" pixel of collage 
function [outImg,outLoc]=predictOnSpecLocCollage(server,collage,collageNum,imgdim,location,modelnumber,downscale,basepath,savepath,isThreaded,gpu)
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
    
    svmModel=strcat('/svm',model);    
    workingDirPath=  strcat(basepath,'/pca_data/train/',model);
    modelpath=  strcat(basepath,svmModel);   
    if (~isThreaded && ~gpu)
        fprintf('Processing without thread...');
        [outImg,outLoc] = predictScaledModelLnCollage(collage,[patchH,patchW],location,ModelType.CompactSVM,workingDirPath,modelpath);
    elseif false && isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        % TO BE WRIITEN (IF REQUIRED)
    elseif gpu
       %TO BE WRIITEN (IF REQUIRED) -- IN PROGRESS
       [outImg,outLoc]  = processScaledModelLnCollageGpu2(collage,[patchH,patchW],location,ModelType.CompactSVM,workingDirPath,modelpath);          
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
function outImg=predictOnFullCollage(server,collage,collageNum,imgdim,modelnumber,downscale,basepath,savepath,isThreaded,gpu)

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
    
    svmModel=strcat('/svm',model);    
    workingDirPath=  strcat(basepath,'/pca_data/train/',model);
    modelpath=  strcat(basepath,svmModel);   
    if ~isThreaded && ~gpu
        fprintf('Processing without thread...');
        [ outImg ] = predictScaledModelL1Collage(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath);
    elseif isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        thread=10;
        delete(gcp('nocreate'));
        parpool(thread)
        [outCell] = predictScaledModelL1CollageCPUThread(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath,thread);       
        [outImg]=mergeParallelCollage(outCell,[patchH,patchW],collageSize);
        
    elseif gpu
        [outCell] = processScaledModelL1CollageGpu2(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath);
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
        offset=(i-1)*threadImgHeight+1;
        x1=offset-floor(halfPatchH);
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