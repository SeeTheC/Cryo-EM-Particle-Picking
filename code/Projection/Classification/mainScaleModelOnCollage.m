%% Run on Collage
% sample call: mainScaleModelOnCollage(0,[333,333],3)
function [ status ] =  mainScaleModelOnCollage(server,imgdim,noOfScale)
    status='failed';
    %% Init    
    if server
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
    end
    % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
    basepath=strcat(basepath,'/_data-Y,Z','v.10');
    testPath=strcat(basepath,'/test');
    testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');
    savepath= strcat(testPath,'/collage1_6x6','/processed_img/');    
    struct=load(testCollagePath);
    collage=struct.img;
    
    isThreaded=0
    gpu=1
    %% Perdict
    modelnumber=3;
    downscale=4;
    predictOnFullCollage(server,collage,imgdim,modelnumber,downscale,basepath,savepath,isThreaded,gpu)    
    status='completed';
end

% It will find probabilty score at every pixel of collage using the
% overlapping patches
function predictOnFullCollage(server,collage,imgdim,modelnumber,downscale,basepath,savepath,isThreaded,gpu)

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
    model=strcat('/model_1-2-4/svm/model-',num2str(modelnumber));    
    workingDirPath=  strcat(basepath,'/model_1-2-4/','/pca_data/train/','/model-',num2str(modelnumber));
    modelpath=  strcat(basepath,model);   
    if ~isThreaded && ~gpu
        fprintf('Processing without thread...');
        [ outImg ] = predictScaledModelOnCollage(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath);
    elseif isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        thread=10;
        delete(gcp('nocreate'));
        parpool(thread)
        [outCell] = predictScaledModelOnCollageCPUThread(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath,thread);       
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
    mkdir(savepath);
    tmpImg=outImg-min(outImg(:));tmpImg=tmpImg./max(tmpImg(:));
    imwrite(tmpImg,strcat(savepath,'/',num2str(1),'.jpg'));
    save(strcat(savepath,'/',num2str(1),'.mat'),'outImg');
end

% In Thread mode: merge the differnent parts of collage
%  cellDim= [333,333] 
%  gridDim= [6,6]
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