% Init
% Load Fisher's iris data set.
load fisheriris
%% 1. SVM - using Method SMO : Sequential Minimal Optimization 
figure('name','Train-Data Classification');
xdata = meas(51:end,3:4);
group = species(51:end);

options = statset('Display','iter');
svmStruct = svmtrain(xdata,group,...
                    'ShowPlot',true,...
                    'options',options);                
% 1.1 Classification on Test
Xnew = [5 2; 4 1.5];
species = svmclassify(svmStruct,Xnew,'ShowPlot',true)
hold on;
plot(Xnew(:,1),Xnew(:,2),'ro','MarkerSize',12);
hold off

%% 2. Using FITCSVM Same but new library
inds = ~strcmp(species,'setosa');
X = meas(inds,3:4);
y = species(inds);

% Creating SVM Model
%SVMModel:  It is a trained ClassificationSVM classifier and has a property list.
SVMModel = fitcsvm(X,y)

%% Plotting
sv = SVMModel.SupportVectors;
figure
gscatter(X(:,1),X(:,2),y)
hold on
plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
legend('versicolor','virginica','Support Vector')
hold off


%% 4. Detail FITCSVM - WIth Cross validation
clear all;
% data
load ionosphere
rng(1); % For reproducibility

cvp= cvpartition(size(X,1),'KFold',5);
% Standardize: mean normalize each col of the Train dataset
SVMModel = fitcsvm(X,Y, ...
            'Standardize',true, ...
            'KernelFunction','RBF',...           
            'KernelScale','auto',...    
            'CVPartition',cvp ...
          )
%,'CacheSize','maximal' 

%% 4.1 Predict values
[label,score] = predict(SVMModel,X);







