%% Predict Labels and Posterior Probabilities of SVM Classifiers

%% Init
clear all;
load ionosphere

n = size(X,1);       % Training sample size
isInds = 1:(n-10);   % In-sample indices
oosInds = (n-9):n;   % Out-of-sample indices

%% Train
SVMModel = fitcsvm(X(isInds,:),Y(isInds),'Standardize',true,...
    'ClassNames',{'b','g'});
CompactSVMModel = compact(SVMModel);
whos('SVMModel','CompactSVMModel')

% NOTE: The CompactClassificationSVM classifier (CompactSVMModel) uses less space 
% than the ClassificationSVM classifier (SVMModel) because the latter stores the data

%% Estimate the optimal score-to-posterior-probability-transformation function.

CompactSVMModel = fitPosterior(CompactSVMModel,X(isInds,:),Y(isInds))

%%  Predict
[labels,PostProbs] = predict(CompactSVMModel,X(oosInds,:));
table(Y(oosInds),labels,PostProbs(:,2),'VariableNames',...
    {'TrueLabels','PredictedLabels','PosClassPosterior'})
