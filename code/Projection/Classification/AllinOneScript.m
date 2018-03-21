%% Run on Collage

clear all;
rng(1);
basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/';
collagePath= strcat(basepath,'/Collage2/raw_img/','1.mat');
savedImgDir= strcat(basepath,'/Collage2/processed_img/');
struct=load(collagePath);
collage=struct.img;
% patchH == cellH of collage and patchW == cellW of collage
patchH=333;patchW=333;
collage=collage(1:patchH,:);
%% Show OriginalCollage
figure('name','Original Collage');
imshow(collage,[]);

%% 1. SVMv1.0
% Load Trained Model
svnTrainedModelPath= strcat(basepath,'/_pca_data-Y,Z,Neg','v.10','/compactSVMModel.mat');
struct=load(svnTrainedModelPath);
compactSVMModel=struct.compactSVMModel;
%whos('compactSVMModel')
%% Temp

%% 1.1 SVMv1.0 - Process college
tic
workinfDirPath=  strcat(basepath,'/_pca_data-Y,Z,Neg','v.10');
predictOnCollage(collage,[patchH,patchW],ModelType.CompactSVM,workinfDirPath);

%%


%%
 
 
 fprintf('Done Processing..\n');
toc
%% Save
%figure('name','Predicted Collage');
%imshow(outImg,[]);
mkdir(savedImgDir);
mwrite(uint8(outImg),strcat(savedImgDir,'/',num2str(1),'.jpg'));



