%% Run on Collage

clear all;
rng(1);

server = 0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
basepath=strcat(basepath,'/_data-Y,Z','v.10');

trainPath=strcat(basepath,'/train');
testPath=strcat(basepath,'/test');

testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');
savedImgDir= strcat(testPath,'/collage1_6x6','/processed_img/');


struct=load(testCollagePath);
collage=struct.img;
% patchH == cellH of collage and patchW == cellW of collage
patchH=333;patchW=333;
collage=collage(1:patchH,:);

%% Show OriginalCollage
%figure('name','Original Collage');
%imshow(collage,[]);

%% 1. SVMv1.0
% Load Trained Model
svnTrainedModelPath= strcat(basepath,'/pca_data','/compactSVMModel.mat');
struct=load(svnTrainedModelPath);
compactSVMModel=struct.compactSVMModel;
%whos('compactSVMModel')
%% Temp

%% 1.1 SVMv1.0 - Process college
tic
workinfDirPath=  strcat(basepath,'/pca_data/train/');
[ outImg ] = predictOnCollage(collage,[patchH,patchW],ModelType.CompactSVM,workinfDirPath);
fprintf('Done Processing..\n');
toc
%% Save
%figure('name','Predicted Collage');
%imshow(outImg,[]);
mkdir(savedImgDir);
imwrite(uint8(outImg),strcat(savedImgDir,'/',num2str(1),'.jpg'));
save(strcat(savedImgDir,'/',num2str(1),'.mat'),'outImg');



