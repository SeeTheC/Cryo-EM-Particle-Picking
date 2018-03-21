% Used for generating multi scale model
% Call: genSVMModelv2_0(1,3)
function [ status ] = genSVMModelv2_0(server,noOfScales)
    %% INIT        
    status='fail';                
    if server
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
    end
    % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
    basepath=strcat(basepath,'/_data-Y,Z','v.10','/model_1-2-4');
     %% Generating SVM Model
    for i=1:noOfScales 
           fprintf('.............Generating SVM Model:%d..............\n',i);
           generate(i,basepath);
    end
    status='complete';
end

function generate(modelNumber,basepath)

    datapath= strcat(basepath,'/pca_data');
    trainFile= strcat(datapath,'/train','/model-',num2str(modelNumber),'/complete_data_coeff.txt');
    testFile= strcat(datapath,'/test','/model-',num2str(modelNumber),'/complete_data_coeff.txt');
    savepath = strcat(basepath,'/svm/','/model-',num2str(modelNumber));
    mkdir(savepath);
    %trainFile= strcat(datapath,'/train_set1.txt');
    %testFile= strcat(datapath,'/test_set1.txt');
    fid = fopen(strcat(savepath,'/svm_info.txt'), 'w+');
    
    %% Reading Train and Test dataset    
    trainDataSet=load(trainFile);
    testDataSet=load(testFile);

    randomIndex=randperm(size(trainDataSet,1),size(trainDataSet,1));
    trainDataSet=trainDataSet(randomIndex,:);
    randomIndex=randperm(size(testDataSet,1),size(testDataSet,1));
    testDataSet=testDataSet(randomIndex,:);
    %% Separating data and label
    validateSet=0.2; 
    fprintf(fid,'Validate percent:%f\n',validateSet);
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
    fprintf(fid,'# Train DataPoint:%d\n',noOfTrainDataPt);
    fprintf(fid,'# Test DataPoint:%d\n',size(testDataSet,1));
    
    %% 1. Traing: SVM Model

    svmModel = fitcsvm(trainX,trainY, ...
                        'ClassNames',{'-1','1'},... 
                        'IterationLimit',1e8,...
                        'Standardize',true);

    %%              
    % Extract trained, compact classifier
    %compactSVMModel = compact(svmModel);
    compactSVMModel = svmModel.fitPosterior();
    compactSVMModel = compact(compactSVMModel);
    clear svmModel;
    %% Save Trained Model
    save(strcat(savepath,'/compactSVMModel.mat'),'compactSVMModel');
    clear compactSVMModel;
    %% Load Trained Model
    struct=load(strcat(savepath,'/compactSVMModel.mat'));
    compactSVMModel=struct.compactSVMModel;
    whos('compactSVMModel')

    %% Validate test
    [predLabelCell,PostProbs] = predict(compactSVMModel,validateX);

    table(validateY,predLabelCell,PostProbs(:,2),'VariableNames',{'TrueLabels','PredictedLabels','PosClassPosterior'})

    trueLabel=validateY;
    [validateAccuracy ] = getAccuracy(trueLabel,predLabelCell);

    fprintf('Validate Accuracy: %f\n',validateAccuracy);
    fprintf(fid,'Validate Accuracy: %f\n',validateAccuracy);
    
    %% 3. Check for Test set

    [predLabelCell,PostProbs] = predict(compactSVMModel,testX);
    table(testY,predLabelCell,PostProbs(:,2),'VariableNames', {'TrueLabels','PredictedLabels','PosClassPosterior'})

    trueLabel=testY;
    [ testAccuracy ] = getAccuracy(trueLabel,predLabelCell);
    fprintf('Test Accuracy: %f\n',testAccuracy);
    fprintf(fid,'Test Accuracy: %f\n',testAccuracy);
    fclose(fid);
end
