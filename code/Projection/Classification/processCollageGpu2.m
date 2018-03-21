function [ output ] = processCollageGpu2()
%% INIT 1.0
rng(1);
server = 0
gpu=0

thread=2;

%delete(gcp('nocreate'));
%fprintf('Creating Threads..');
%parpool(thread)
%pool = gcp();

if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
basepath=strcat(basepath,'/_data-Y,Z','v.10');
testPath=strcat(basepath,'/test');
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');
savedImgDir= strcat(testPath,'/collage1_6x6','/processed_img/');
dirPath=  strcat(basepath,'/pca_data/train/');

struct=load(testCollagePath);
collage=struct.img;
% patchH == cellH of collage and patchW == cellW of collage
patchH=333;patchW=333;
patchDim=[patchH,patchW];
[H,W]=size(collage); 
collage=collage(1:patchH,:);

%% Init 2.0
patchH=patchDim(1);patchW=patchDim(2);    
halfPatchH=patchH/2;halfPatchW=patchW/2;
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);


%% SVM
fprintf('Loading PCA coefficent....');
svm_pcaCoeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
svm_pcamu=dlmread(strcat(dirPath,'/data_mean.txt'));
svm_pcamu=svm_pcamu';
struct=load(strcat(dirPath,'/compactSVMModel.mat'));
trainedModel=struct.compactSVMModel;  
modelType=ModelType.CompactSVM;
fprintf('Done ..\n');
%% Gpu

if gpu ==1 
    fprintf('Gpu: init...');
    svm_pcaCoeff=gpuArray(svm_pcaCoeff);
    svm_pcamu=gpuArray(svm_pcamu);
    collage=gpuArray(collage);
    fprintf('Done \n');    
end

%%
function [ feature ] = method1(cellCol)   
     vector=cellCol{1};   
     feature=bsxfun(@minus,vector,svm_pcamu)*svm_pcaCoeff;  
     clear vector;
     %feature=gather(feature);
     %[~,positiveScore] = perdictLabel(modelType,trainedModel,feature);
     %num=positiveScore;     
end

%%
tic
fprintf('Creating Cell Array array...');
colmat=im2col(collage,patchDim);
dim=ones(1,size(colmat,2));
cellColl = mat2cell(colmat',dim);
clear colmat;
fprintf('Done...\n');
toc
%%
tic
fprintf('Processing...');
b=arrayfun(@method1,cellColl(1:2),'UniformOutput',false);
output=b;
fprintf('Done...\n');
toc

fprintf('Finding Prediction...');
tic
n=size(b,1);
output=zeros(size(cellColl,2),1);  
clear cellColl;
feature=gather(b);
parfor i=1:n    
    [~,positiveScore] = perdictLabel(modelType,trainedModel,feature(i));
    output(i)=positiveScore; 
end
toc
%}
%%
end

