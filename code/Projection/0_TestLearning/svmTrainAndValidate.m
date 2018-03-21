%% 3. Train and Predict
%% Init
clear all;
load ionosphere
rng(1); % For reproducibility

%% 1. Train
% Holdout: Preserve 15% of the data as Validation Set
% 'ClassNames',{'b','g'} b: is -ve class and g is +ve class
% Standardize: Normalization

CVSVMModel = fitcsvm(X,Y, ...
                    'Holdout',0.15,...
                    'ScoreTransform','logit',...
                    'ClassNames',{'b','g'},...                    
                    'Standardize',true);
                
CompactSVMModel = CVSVMModel.Trained{1} % Extract trained, compact classifier
testInds = test(CVSVMModel.Partition);   % Extract the test indices
XTest = X(testInds,:);
YTest = Y(testInds,:);

%% 2.1 Predict on Validate Set
[label,score] = predict(CompactSVMModel,XTest);
table(YTest(1:10),label(1:10),score(1:10,2),'VariableNames',...
    {'TrueLabel','PredictedLabel','Score'})

%% 