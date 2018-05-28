% Used for generating multi scale model
% Call: genSVMModelv2_0(1,3)
function [ status ] = randomForestv2(server,noOfScales)
    %% INIT        
    status='fail';                
    if server
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    else
        basepath='/home/ayush/mtech/subj4/aip/project';  
    end
    % SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
    basepath=strcat(basepath,'/_data-proj-5689v.20'); 
    basepath=strcat(basepath,'/Noisy_downscale500');
    %basepath=strcat(basepath,'/_data-Y,Z','v.10','/Noisy_downscale2');         
    %basepath=strcat(basepath,'/_data-proj-2211','v.10');        
    
    basepath=strcat(basepath,'/model_1-2-4');
    
     %% Generating SVM Model
    for i=1:noOfScales 
           fprintf('.............Generating random Forest Model:%d..............\n',i);
           generate(i,basepath);
    end
    status='complete';
end

function generate(modelNumber,basepath)

    datapath= strcat(basepath,'/pca_data');
    trainFile= strcat(datapath,'/train','/model-',num2str(modelNumber),'/complete_data_coeff.txt');
    testFile= strcat(datapath,'/test','/model-',num2str(modelNumber),'/complete_data_coeff.txt');
    savepath = strcat(basepath,'/rf/','/model-',num2str(modelNumber));
    mkdir(savepath);
    %trainFile= strcat(datapath,'/train_set1.txt');
    %testFile= strcat(datapath,'/test_set1.txt');
    fid = fopen(strcat(savepath,'/rf_info.txt'), 'w+');
    
    
    %% Reading Train and Test dataset
    trainDataSet=load(trainFile);
    testDataSet=load(testFile);

    randomIndex=randperm(size(trainDataSet,1),size(trainDataSet,1));
    trainDataSet=trainDataSet(randomIndex,:);
    randomIndex=randperm(size(testDataSet,1),size(testDataSet,1));
    testDataSet=testDataSet(randomIndex,:);
    
    fprintf('here');
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
    fprintf(fid,'# Train DataPoint:%d\n',noOfTrainDataPt);
    fprintf(fid,'# Test DataPoint:%d\n',size(testDataSet,1));
                    
    %% 1. Traing: random forest Model

    rfModel = TreeBagger(50,trainX,trainY, ...
                    'ClassNames',{'-1','1'});
                
    %% Save Trained Model
    save(strcat(savepath,'/rfModel.mat'),'rfModel');
    clear rfModel;
    %clear compactSVMModel;
    %% Load Trained Model
    struct=load(strcat(savepath,'/rfModel.mat'));
    RFModel=struct.rfModel;
    whos('RFModel')


    %% validate test
    [predLabelCell,PostProbs] = predict(RFModel,validateX);

    table(validateY,predLabelCell,PostProbs(:,2),'VariableNames',{'TrueLabels','PredictedLabels','PosClassPosterior'})

    trueLabel=validateY;
    [validateAccuracy ] = getAccuracy(trueLabel,predLabelCell);
    fprintf('Validate Accuracy: %f\n',validateAccuracy);
    fprintf(fid,'Validate Accuracy: %f\n',validateAccuracy);
  
    
    %% 3. Check for Test set

    [predLabelCell,PostProbs] = predict(RFModel,testX);
    table(testY,predLabelCell,PostProbs(:,2),'VariableNames', {'TrueLabels','PredictedLabels','PosClassPosterior'})

    trueLabel=testY;
    [ testAccuracy ] = getAccuracy(trueLabel,predLabelCell);

    fprintf('Test Accuracy: %f\n',testAccuracy);
    fprintf(fid,'Test Accuracy: %f\n',testAccuracy);
    fclose(fid);
    
    
end