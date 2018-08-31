%% Partilce Recognitiong using Faster R-CNN: Train
%% Init: Config
clear all;
fprintf('Initializing..\n');
server=2;
if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end 

timestamp=datestr(now,'dd-mm-yyyy_HH-MM-SS');
timestamp=strcat('ts_',timestamp);

%----------------------------[Config:1]--------------------------------------
dataset='_dl-proj-10025v.10_mghw_1000';

trainNewModel=true;
checkpointing=false;
valPercent=0.2;
maxTrainDatasetSize=6000;
smallestImageDimension= 400; % used in faster RCNN

trainFrmChkPtModelPath='';% used when trainNewModel= true && checkpointing =true
trainFrmChkPtModelChkptName=''; % used when trainNewModel= true && checkpointing=true
trainedModelpath='model_self_3';% used when trainNewModel = false i.e for loading already trained model
%--------------------------------------------------------------------------

basepath = strcat(basepath,'/',dataset);
trainPath=strcat(basepath,'/Train_Preprocess1');
trainImgPath=strcat(trainPath,'/img');
trainBboxPath=strcat(trainPath,'/train_bbox.csv');

testPath=strcat(basepath,'/Test_Preprocess1');
testImgPath=strcat(testPath,'/img');
testBboxPath=strcat(testPath,'/test_bbox.csv');

savedBasepath=strcat(basepath,'/trained_model');
savemodel=strcat(savedBasepath,'/model_',timestamp);

if trainNewModel && checkpointing   
    fprintf('\n Laoding Check point...\n') 
    savemodel=strcat(savedBasepath,'/',trainFrmChkPtModelPath);
    checkpointModelPath=strcat(savemodel,'/checkpoint/',trainFrmChkPtModelChkptName);
end
if ~trainNewModel
    savedModelPath=strcat(savedBasepath,'/',trainedModelpath);
end


% Creatining dir
mkdir(savedBasepath);
mkdir(savemodel);
fprintf('Done.\n');
%% Init Dataset

% Reading T20Protosome dataset
fprintf('Init T20Protosome dataset filepath..\n');
trainDataset=readBboxCsv(trainBboxPath);
trainDataset.Properties.VariableNames={'filename','box'};
fprintf('Completed..\n');
% Creating full path
trainDataset.filename = fullfile(trainImgPath, trainDataset.filename);
fullTrainDataset=trainDataset(1:min(maxTrainDatasetSize,size(trainDataset,1)),:);

% Display first few rows of the data set.
fullTrainDataset(1:2,:)
% full path
fullTrainDataset(1:2,:)
fprintf('Done.\n');
%% Visualizing Dataset 
% Read one of the images.
imgNo=12;
downscale=3;
img = imread(fullTrainDataset.filename{imgNo});
img1=imresize(img,1/downscale);
img1=double(img1-min(img1(:)));
img1=img1./max(img1(:));
%bbox=[379,615,216,216;240,187,216,216;71,421,216,216];
bbox=fullTrainDataset.box{imgNo};
I = insertShape(img1, 'Rectangle', bbox./downscale);
figure
imshow(I,[]);
%%img3 = wiener2(adapthisteq(imcomplement(img)),[5 5]);
%%figure,imshow(img3,[])
%% Mark Center
addpath(genpath('../Classification/DrawBox/'));
centoroid=bbox+108;
centoroid = centoroid(:,[2 1]);
drawingConfig.originalMg=double(img);
%drawingConfig.visualDownsample=config.downscale;  
drawingConfig.visualDownsample=3;
%drawingConfig.downscaleModel=config.downscale;
drawingConfig.predictedLoc=centoroid;
drawingConfig.trueKnownLoc=[];
drawingConfig.savepath='.';    
% MarkCenter
[predImg,predTrueImg] = markCenterParticle(drawingConfig);
figure,imshow(predImg);
%% Creating Training anf validation Set
idx = floor((1-valPercent) * height(fullTrainDataset));
trainingData = fullTrainDataset(1:end,:);
valData = trainDataset(4000+1:end,:);
%% Creating Arch
%[layers,options,minInputDim]=createRCNNArchAlexNet(2,savemodel);
[layers,options,minInputDim]=createRCNNArch2(2,savemodel);
%[layers,options,minInputDim]=createRCNNArchVGG16(2,savemodel);

if checkpointing
    data=load(checkpointModelPath);
    layers=data.detector;
end
layers
%% Train
tic
if trainNewModel
    fprintf('Started training..\n');
    rng(0);    
    % Train Faster R-CNN detector. Select a BoxPyramidScale of 1.2 to allow
    % for finer resolution for multiscale object detection.  
    %        'SmallestImageDimension', 200, ...
    detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.65 1], ...   
        'SmallestImageDimension',smallestImageDimension,...
        'BoxPyramidScale', 1.2);
    
    savepath=strcat(savemodel,'/','detector.mat');
    save(savepath,'detector');
    fprintf('Completed..\n');
else
    fprintf('Loading Pretrained Model..\n');
    % Loading Saved Model
    modelpath=strcat(savedModelPath,'/','detector.mat');
    sobj=load(modelpath);
    detector=sobj.detector; 
    fprintf('Completed..\n');
    
end
toc
%% TEST on one Image
fprintf('Testing on image..\n')
% Read a test image.
%tempDS.filename = fullfile(trainImgPath, trainDataset.filename);
%I = imread(valData.filename{2});

% Full Micrograph
addpath(genpath('../MapFileReader/'));
mgName='14sep05c_c_00004gr_00032sq_00015hl_00004es.mrc';
%mgName='14sep05c_00024sq_00003hl_00002es_c.mrc';
mgFile=strcat(basepath,'/10025/data/14sep05c_averaged_196/',mgName);
[mg,~,~,~,~]=ReadMRC(mgFile);
mg=mg-min(mg(:));
mg=mg./max(mg(:));
%%
Iimg = imread(trainDataset.filename{12});
%Iimg=mg;
I=imresize(Iimg,1/2.5);
%hI=histeq(I);
%I=hI;
%I=Iimg;
% Run the detector.

[bboxes,scores] = detect(detector,I);
% Annotate detections in the image.
if size(bboxes,1)>0
    I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
else
    fprintf('**NO Particle FOUND\n')
end
figure
imshow(I)
%%
valData = trainDataset(4001:end,:);
%%  Testing result
fprintf('\n-----------------[Testing PHASE]-------------------------------\n');
downsample=2.5;
if trainNewModel    
    [avgPrecision,result,tblPrecsionRecall] = predictOnTestDataset(detector,minInputDim,valData,downsample,savemodel);    

else
    resultpath=testBboxPath
    if  ~exist(resultpath)
        [avgPrecision,result,tblPrecsionRecall] = predictOnTestDataset(detector,minInputDim,valData,savedModelPath);    
    else 
        prPath=strcat(savedModelPath,'/','precision_recall.mat');
        fprintf('Loading Pretrained Result..\n');
        % Loading Saved Model
        sobj=load(resultpath);
        result=sobj.result; 
        sobj=load(prPath);
        tblPrecsionRecall=sobj.tbl;         
        fprintf('Completed..\n');
    end
end
tblPrecsionRecall
fprintf('**Avg Precision of Dectector:%f ',avgPrecision);
%% Plot of Precision and Recall
figure
plot(tblPrecsionRecall.recall,tblPrecsionRecall.precision)
grid on
title(sprintf('Average Precision = %.1f\n',avgPrecision))


 
