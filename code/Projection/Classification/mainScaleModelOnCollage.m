%% Run on Collage
% sample call: perdictScaleModelOnCollage(0,[333,333],3)
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
    
    %% Perdict
    modelnumber=3;
    downscale=4;
    predictOnFullCollage(server,collage,imgdim,modelnumber,downscale,basepath,savepath)    
    status='completed';
end

% It will find probabilty score at every pixel of collage using the
% overlapping patches
function predictOnFullCollage(server,collage,imgdim,modelnumber,downscale,basepath,savepath)

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
    model=strcat('/model_1-2-4/svm/model-',num2str(modelnumber));    
    workingDirPath=  strcat(basepath,'/model_1-2-4/','/pca_data/train/','/model-',num2str(modelnumber));
    modelpath=  strcat(basepath,model);
    isThreaded=0
    gpu=0
    if ~isThreaded && ~gpu
        fprintf('Processing without thread...');
        [ outImg ] = predictScaledModelOnCollage(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath);
    elseif isThreaded && ~gpu
        fprintf('Processing with CPU thread...');
        thread=10;
        delete(gcp('nocreate'));
        parpool(thread)
        [ outImg ] = predictScaledModelOnCollageCPUThread(collage,[patchH,patchW],ModelType.CompactSVM,workingDirPath,modelpath,thread);       
    end
    fprintf('Done Processing..\n');
    toc
    %% Save
    if ~server
        figure('name','Predicted Collage');
        imshow(outImg,[]);
    end
    mkdir(savepath);
    imwrite(uint8(outImg),strcat(savepath,'/',num2str(1),'.jpg'));
    save(strcat(savepath,'/',num2str(1),'.mat'),'outImg');
end