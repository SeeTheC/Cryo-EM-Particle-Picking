% This is Single train model i.e not scaleup model 
%% 2-Class Classification using Random Forest on Virus Projection Image
% Feature uses as PCA base dimensional reduction

%% INIT - Reading Data Set
clear all;
rng(1);
server = 0;
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/home/ayush/mtech/subj4/aip/project';  
end
% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE

basepath=strcat(basepath,'/_data-Y,Z','v.10');

datapath= strcat(basepath,'/pca_data');
trainFile= strcat(datapath,'/train/complete_data_coeff.txt');
testFile= strcat(datapath,'/test/complete_data_coeff.txt');

%trainFile= strcat(datapath,'/train_set1.txt');
%testFile= strcat(datapath,'/test_set1.txt');

%% Reading Train and Test dataset
trainDataSet=load(trainFile);
testDataSet=load(testFile);

randomIndex=randperm(size(trainDataSet,1),size(trainDataSet,1));
trainDataSet=trainDataSet(randomIndex,:);
randomIndex=randperm(size(testDataSet,1),size(testDataSet,1));
testDataSet=testDataSet(randomIndex,:);
%%
% Separating data and label
validateSet=0.15; 
noOfTrainDataPt=size(trainDataSet,1);
validateCount=ceil(noOfTrainDataPt*validateSet);
trainDataSet=trainDataSet(1:end-validateCount,:);
validateDataSet=trainDataSet(end-validateCount+1:end,:);

trainX=trainDataSet(:,1:end-1); trainY=trainDataSet(:,end); 
%clear trainDataSet;
validateX=validateDataSet(:,1:end-1); validateY=validateDataSet(:,end); 
%clear validateDataSet;
testX=testDataSet(:,1:end-1); testY=testDataSet(:,end); 
%clear testDataSet;

%% 1. Traing: random forest Model

rfModel = TreeBagger(50,trainX,trainY, ...
                    'ClassNames',{'-1','1'});

%%              
% Extract trained, compact classifier
%compactSVMModel = compact(svmModel);
%compactSVMModel = svmModel.fitPosterior();
%compactSVMModel = compact(compactSVMModel);
%clear svmModel;
%% Save Trained Model




save(strcat(datapath,'/rfModel.mat'),'rfModel');
clear rfModel;
%clear compactSVMModel;
%% Load Trained Model
struct=load(strcat(datapath,'/rfModel.mat'));
RFModel=struct.rfModel;
whos('RFModel')

%% validate test
[predLabelCell,PostProbs] = predict(RFModel,validateX);

table(validateY,predLabelCell,PostProbs(:,2),'VariableNames',{'TrueLabels','PredictedLabels','PosClassPosterior'})

trueLabel=validateY;
[validateAccuracy ] = getAccuracy(trueLabel,predLabelCell);
 
fprintf('Validate Accuracy: %f\n',validateAccuracy);
%% 3. Check for Test set

[predLabelCell,PostProbs] = predict(RFModel,testX);
table(testY,predLabelCell,PostProbs(:,2),'VariableNames', {'TrueLabels','PredictedLabels','PosClassPosterior'})

trueLabel=testY;
[ testAccuracy ] = getAccuracy(trueLabel,predLabelCell);
 
fprintf('Test Accuracy: %f\n',testAccuracy);
