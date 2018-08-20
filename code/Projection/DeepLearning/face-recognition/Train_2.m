%% Face Recognitiong using Faster R-CNN: Train
%% Init: Config
clear all;
%----------------------------[Config]--------------------------------------
fprintf('Initializing..\n');
server = 1
if server 
    basepath = '~/git/Face-Recognition-using-Faster-R-CNN/data';
else
    basepath = '../data';
end
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
timestamp=strcat('Kali_',timestamp);

basepath = strcat(basepath,'/Wider');
%basepath = strcat(basepath,'/Wider_MIN_16x16');
savedBasepath=strcat(basepath,'/trained_model');
savemodel=strcat(savedBasepath,'/model_',timestamp);

trainNewModel=true;
checkpointing=false;

if trainNewModel && checkpointing   
    fprintf('\n Laoding Check point...\n') 
    savemodel=strcat(savedBasepath,'/model_Kali_arch3');
    checkpointModelPath=strcat(savemodel,'/checkpoint/','/faster_rcnn_stage_1_checkpoint__103000__2018_04_27__23_49_11.mat');
end
if ~trainNewModel
    savedModelPath=strcat(savedBasepath,'/train_200');
end

valPercent=0.2;
%-------------------------------------------------------------------------

% Creatining dir
mkdir(savedBasepath);
mkdir(savemodel);
%% Init Dataset

% Reading Wider dataset
fprintf('Init Wider dataset filepath..\n');
matPath = strcat(basepath,'/wider_face_split');
trainFile= strcat(matPath,'/parse_train_dataset.mat');
testFile= strcat(matPath,'/parse_val_dataset.mat');
fullTrainDataset=load(trainFile);
fullTrainDataset=fullTrainDataset.dataset;
fprintf('Completed..\n');
fullTrainDataset.Properties.VariableNames={'filename','box'};

fullTrainDataset=fullTrainDataset(1:600,:);

% Display first few rows of the data set.
fullTrainDataset(1:2,:)
% Creating full path
fullTrainDataset.filename = fullfile(basepath, fullTrainDataset.filename);
% full path
fullTrainDataset(1:2,:)

%% Visualizing Dataset 
% Read one of the images.
imgNo=8;
I = imread(fullTrainDataset.filename{imgNo});
I = insertShape(I, 'Rectangle', fullTrainDataset.box{imgNo});
figure
imshow(I);
%% Creating Training anf validation Set
idx = floor((1-valPercent) * height(fullTrainDataset));
trainingData = fullTrainDataset(1:end,:);
%valData = fullTrainDataset(idx:end,:);
%% Creating Arch
[layers,options,minInputDim]=createRCNNArch3(2,savemodel);
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
        'SmallestImageDimension',600,...
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
I = imread(valData.filename{2});

% Run the detector.
[bboxes,scores] = detect(detector,I);

% Annotate detections in the image.
if size(bboxes,1)>0
    I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
else
    fprintf('**NO FACE FOUND')
end
figure
imshow(I)
%%  Testing result
fprintf('\n-----------------[Testing PHASE]-------------------------------\n');
if trainNewModel    
    [avgPrecision,result,tblPrecsionRecall] = predictOnTestDataset(detector,minInputDim,valData,savemodel);    

else
    resultpath=strcat(savedModelPath,'/','test_result.mat');
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


 
