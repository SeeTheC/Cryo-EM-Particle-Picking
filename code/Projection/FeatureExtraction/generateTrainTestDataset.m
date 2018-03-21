% Seperate the Single datafile into Train test data
function [ output] = generateTrainTestDataset(datafileDir,dataFileName,testDateInPercent)
    output='Error';
    dataset=load(strcat(datafileDir,'/',dataFileName));
    totalNoOfDataPt=size(dataset,1);
    noOfTrainPt=ceil(( (100-testDateInPercent)/100)*totalNoOfDataPt);
    randomIndex=randperm(totalNoOfDataPt,totalNoOfDataPt);
    dataset=dataset(randomIndex,:);
    trainData=dataset(1:noOfTrainPt,:);
    testData=dataset(noOfTrainPt:end,:);
    %save data
    dlmwrite(strcat(datafileDir,'/','train.txt'),trainData);
    dlmwrite(strcat(datafileDir,'/','test.txt'),testData);
    output='Successfully generated train & test set';
    fprintf('Successfully generated train & test set. See dir:\n %s\n',datafileDir);
end

