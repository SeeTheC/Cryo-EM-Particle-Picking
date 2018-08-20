%% Partilce Recognitiong using Faster R-CNN: Train
%% Init: Config
clear all;
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification/DrawBox/'));
addpath(genpath('../../EM-Micrograph/script'));
fprintf('Initializing..\n');
server=2
if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end 

%----------------------------[Config:1]--------------------------------------
dataset='_dl-proj-10025v.10_mghw_1000';
%mgName='14sep05c_00024sq_00003hl_00002es_c.mrc';
mgName='14sep05c_c_00004gr_00032sq_00015hl_00004es_c'
trainedModelpath='model_selfArch';% used when trainNewModel = false i.e for loading already trained model
%--------------------------------------------------------------------------
datasetPath = strcat(basepath,'/',dataset);
coordMetadataPath=strcat(basepath,'/10025/','run1_shiny_mp007_data_dotstar.txt.star');    
savedBasepath=strcat(datasetPath,'/trained_model');
savedModelPath=strcat(savedBasepath,'/',trainedModelpath);
fprintf('Done.\n');
%% Loading Trained Model
     
fprintf('Loading Pretrained Model..\n');
% Loading Saved Model
modelpath=strcat(savedModelPath,'/','detector.mat');
sobj=load(modelpath);
trainedModel=sobj.detector; 
fprintf('Completed..\n');
    
%%  Loading Micrograph
fprintf('Testing on image..\n')
mgFile=strcat(basepath,'/10025/data/14sep05c_averaged_196/',mgName,'.mrc');
[micrograph,~,~,~,~]=ReadMRC(mgFile);
%% Predict on collage
fprintf('Predicting on Single Micrograph...\n');
downsample=2.5;
[predLoc]=predictOnFullMicrograph(trainedModel,micrograph,downsample);
fprintf('Done.');
%% Mark points
% Fetching True cordinates
[trueKnownCoord,keyword]=getRelionCoordinate(mgName,coordMetadataPath);
%%
drawingConfig.originalMg=micrograph;
drawingConfig.visualDownsample=12;  
%drawingConfig.downscaleModel=downscaleModel;
drawingConfig.predictedLoc=[round(predLoc(:,1)),round(predLoc(:,2))];
drawingConfig.trueKnownLoc=trueKnownCoord;
drawingConfig.savepath='.';
% MarkCenter
[predImg,predTrueImg] = markCenterParticle(drawingConfig);
imshow(predTrueImg);
