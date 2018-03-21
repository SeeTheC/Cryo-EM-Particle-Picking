%% Run on Collage
function [ status ] =  perdictScaleModelOnCollage(server,noOfScale)
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
    savedpath= strcat(testPath,'/collage1_6x6','/processed_img/');    
    struct=load(testCollagePath);
    collage=struct.img;
    
    %% Prdict
    status='completed';
end

% It will find probabilty score at every pixel of collage using the
% overlapping patches
function predictOnFullCollage(collage,imgdim,modelnumber,downscale,basepath,savedpath)

    % patchH == cellH of collage and patchW == cellW of collage      
    patchH=ceil(imgdim(1)/downscale);patchW=ceil(imgdim(2)/downscale);
    %collage=collage(1:patchH,:);
    collage=imresize(collage,1/downscale);    
    %% Show OriginalCollage
    figure('name','Original Collage');
    imshow(collage,[]);
   
    %% 1.0 SVMv2.0 - Process college
    tic
    model=strcat('/model_1-2-4/svm/model-',num2str(modelnumber));    
    workinfDirPath=  strcat(basepath,'/pca_data/train/');
    [ outImg ] = predictOnCollage(collage,[patchH,patchW],ModelType.CompactSVM,workinfDirPath);
    fprintf('Done Processing..\n');
    toc
    %% Save
    %figure('name','Predicted Collage');
    %imshow(outImg,[]);
    mkdir(savedImgDir);
    imwrite(uint8(outImg),strcat(savedImgDir,'/',num2str(1),'.jpg'));
    save(strcat(savedpath,'/',num2str(1),'.mat'),'outImg');
end