% It Extract features by downscales.
% Here Features is PCA Space. Scales are 1,2,4,8..
% Lower scaled model will be used for fast destection of object using ML
% methods like SVM, Randomforest etc.

function [ status ] = genFeaturePCAEncoding(server,imgdim,noOfScales,maxNumberSample)
        %% INIT
        status='fail';
        timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
        if server
            basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
        else
            basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
        end
        % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
        
        %basepath=strcat(basepath,'/_data-Y,Z','v.10'); % img dimension: [333,333]
        %basepath=strcat(basepath,'/_data-Y,Z','v.10','/Noisy_downscale2'); % img dimension: [333,333]       
        %basepath=strcat(basepath,'/_data-proj-2211','v.10'); % img dimension: [178,178]       
        %basepath=strcat(basepath,'/_data-proj-5693','v.20'); % img dimension: [333,333]
        basepath=strcat(basepath,'/_data-proj-5689','v.10');  % img dimension: [278,278]

        savepath=strcat(basepath,'/model_',timestamp); 
        mkdir(savepath);
        fid = fopen(strcat(savepath,'/model_info.txt'), 'w+');
        fprintf(fid, '# Model info\n');
        fprintf(fid, 'Inital ImgHeight:%d ImgWidth:%d\n',imgdim(1),imgdim(2));
        fprintf(fid, '# scale: %d\n',noOfScales);
        %% Generating Model
        for i=1:noOfScales 
               downscale=2^(i-1);
               fprintf('.............Generating Model:%d..............\n',i);
               fprintf(fid,'...................[Model %d].............\n',i);
               imgHeight=ceil(imgdim(1)/downscale);imgWidth=ceil(imgdim(2)/downscale);
               generate(server,imgdim,downscale,i,basepath,savepath,maxNumberSample);
               fprintf(fid, 'Model #:%d\tDownsampleBy:%d\tImgDim: [%d,%d]\n',i,downscale,imgHeight,imgWidth);
        end
        fclose(fid);
        status='Completed';
end
function generate(server,imgdim,downscale,modelNumber,basepath,savepath,maxNumberSample)
    %% Init     
    
    % train images
    trainDataPath{1}=strcat(basepath,'/train/raw_img');
    trainNegDataPath{1}=strcat(basepath,'/train/NegImg/raw_img');
    saveDataTrainPath=strcat(savepath,'/train','/model-',num2str(modelNumber));
    savePCATrainPath=strcat(savepath,'/pca_data/train','/model-',num2str(modelNumber));

    % test
    testDataPath{1}=strcat(basepath,'/test/raw_img');
    testNegDataPath{1}=strcat(basepath,'/test/NegImg/raw_img');
    saveDataTestPath=strcat(savepath,'/test','/model-',num2str(modelNumber));
    savePCATestPath=strcat(savepath,'/pca_data/test','/model-',num2str(modelNumber));

    %image dimension
    imgHeight=ceil(imgdim(1)/downscale);imgWidth=ceil(imgdim(2)/downscale);
    
    %% 1. Fetch Train Data Images
    fprintf('Reading +ve Train...');    
    [dataMtx,totalRecord]=getImgDataAsDataMtx(trainDataPath,[imgHeight,imgWidth],downscale,maxNumberSample);
    fprintf('Done. Read %d images\n',totalRecord);
    
    %% 1.1 Finding PCA and Encoding Image Vectors
    fprintf('Finding PCA...');
    [coeff,score,~,~,~,mu]=pca(dataMtx);    fprintf('Done\n');
      
    fprintf('Coeff Dim: %dx%d \n',size(coeff,1),size(coeff,2));
    fprintf('mu Dim: %dx%d \n',size(mu,1),size(mu,2));
    fprintf('Data Coeff Dim: %dx%d \n',size(score,1),size(score,2));
    fprintf('Done Finding PCA.\n');
    %% 1.2 Save +ve data to file
    fprintf('Saving +v Train Data...');
    saveDataPath = saveDataTrainPath;
    savePCAPath = savePCATrainPath;

    mkdir(saveDataPath);
    dlmwrite(strcat(saveDataPath,'/positive_data.txt'),dataMtx);
    % Adding classification lable
    y=zeros(size(dataMtx,1),1);
    y(:)=1;dataMtx=horzcat(dataMtx,y);
    dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx);

    mkdir(savePCAPath);
    dlmwrite(strcat(savePCAPath,'/pca_coeff.txt'),coeff);
    dlmwrite(strcat(savePCAPath,'/data_coeff.txt'),score);
    dlmwrite(strcat(savePCAPath,'/data_mean.txt'),mu);

    % Adding classification lable
    y=zeros(size(score,1),1);
    y(:)=1;score=horzcat(score,y);
    dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),score);
    clear dataMtx;
    clear score;
    fprintf('Done.\n');
    %% 1.3 Fetch -ve Data Images
    fprintf('Reading -ve Train...');    
    [dataMtx,totalRecord]=getImgDataAsDataMtx(trainNegDataPath,[imgHeight,imgWidth],downscale,maxNumberSample);
    fprintf('Done. Read %d images\n',totalRecord);    
    % Finding -ve Data Eigen Coeffient 
    negData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;
    %% 1.4 Save on to the file
    fprintf('Saving -v Train Data...');
    saveDataPath = saveDataTrainPath;
    savePCAPath = savePCATrainPath;

    dlmwrite(strcat(saveDataPath,'/negative_data.txt'),dataMtx);
    dlmwrite(strcat(savePCAPath,'/negdata_coeff.txt'),negData_coeff);

    % Adding classification lable
    y=zeros(size(dataMtx,1),1);
    y(:)=-1;dataMtx=horzcat(dataMtx,y);
    dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx,'-append');

    y=zeros(size(negData_coeff,1),1);
    y(:)=-1;negData_coeff=horzcat(negData_coeff,y);
    dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),negData_coeff,'-append');

    clear dataMtx;
    clear negData_coeff;
    fprintf('Done.\n');
    
    %% 2. TEST DATA
    
    fprintf('Finding eigen coeff for Negative value ... \n');

    %% 2.1 Reading Test Data and Finding its eigen coeff
    fprintf('Reading +ve Test...');    
    [dataMtx,totalRecord]=getImgDataAsDataMtx(testDataPath,[imgHeight,imgWidth],downscale,maxNumberSample);
    fprintf('Done. Read %d images\n',totalRecord);
    
    % Finding -ve Data Eigen Coeffient 
    posData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;

    %% 2.2 Save result
    fprintf('Saving +v Test Data...');
    saveDataPath = saveDataTestPath;
    savePCAPath = savePCATestPath;

    mkdir(saveDataPath);
    mkdir(savePCAPath);

    dlmwrite(strcat(saveDataPath,'/positive_data.txt'),dataMtx);
    dlmwrite(strcat(savePCAPath,'/data_coeff.txt'),posData_coeff);

    % Adding classification lable
    y=zeros(size(dataMtx,1),1);
    y(:)=1;dataMtx=horzcat(dataMtx,y);
    dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx);

    y=zeros(size(posData_coeff,1),1);
    y(:)=1;posData_coeff=horzcat(posData_coeff,y);
    dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),posData_coeff);

    %clear dataMtx;
    clear posData_coeff;
    fprintf('Done.\n');
    
    %% 2.3 TEST DATA: Fetching Negative data
    fprintf('Reading -ve Test...');    
    [dataMtx,totalRecord]=getImgDataAsDataMtx(testNegDataPath,[imgHeight,imgWidth],downscale,maxNumberSample);
    fprintf('Done. Read %d images\n',totalRecord);
    
    % Finding -ve Data Eigen Coeffient 
    negData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;
    %% 2.4 TEST DATA: Save on to the file
    fprintf('Saving -v Test Data...');
    saveDataPath = saveDataTestPath;
    savePCAPath = savePCATestPath;

    dlmwrite(strcat(saveDataPath,'/negative_data.txt'),dataMtx);
    dlmwrite(strcat(savePCAPath,'/negdata_coeff.txt'),negData_coeff);

    % Adding classification lable
    y=zeros(size(dataMtx,1),1);
    y(:)=-1;dataMtx=horzcat(dataMtx,y);
    dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx,'-append');

    y=zeros(size(negData_coeff,1),1);
    y(:)=-1;negData_coeff=horzcat(negData_coeff,y);
    dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),negData_coeff,'-append');

    %clear dataMtx;
    clear negData_coeff;
    fprintf('Done.\n');
    
end

