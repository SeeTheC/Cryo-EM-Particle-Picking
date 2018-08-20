% Seperate +ve positive images into train and test data
fprintf('Seperating +ve positive images into train and test data...\n');
%% Init 
clear all;
server=1;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/RealDataset'; 
    basepath=strcat(basepath,'/Micrograph');
end
%----------------------[Config]------------------------------------
sample='10028';
projection='projection_1';
version='v.10';
% Test Data Percentage
testPercent=25; % i.e 25 %
%------------------------------------------------------------------
datasetPath=strcat(basepath,'/',sample,'/',projection);

dataPath{1,1}=strcat(datasetPath,'/positive/img');
dataPath{1,2}=strcat(datasetPath,'/positive/raw_img');
dataPath{2,1}=strcat(datasetPath,'/negative/img');
dataPath{2,2}=strcat(datasetPath,'/negative/raw_img');


% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
saveBP=strcat(basepath,'/_data-proj-',sample,version,'_ts_',timestamp);
saveTrainDP = strcat(saveBP,'/train');
saveTestDP = strcat(saveBP,'/test');

mkdir(saveTrainDP);
mkdir(saveTestDP);

%% Random Fetch Train and Test data
addpath('../DataCorrection/');
for i=1:2
    if(i==2)        
        saveTrainDP=strcat(saveTrainDP,'/NegImg');mkdir(saveTrainDP);
        saveTestDP=strcat(saveTestDP,'/NegImg');mkdir(saveTestDP);        
    end
    % creating saving path 
    saveTrainDPImg=strcat(saveTrainDP,'/img');mkdir(saveTrainDPImg);
    saveTrainDPRaw=strcat(saveTrainDP,'/raw_img');mkdir(saveTrainDPRaw);
    saveTestDPImg=strcat(saveTestDP,'/img');mkdir(saveTestDPImg);
    saveTestDPRaw=strcat(saveTestDP,'/raw_img');mkdir(saveTestDPRaw);

    fileList=getDirFilesName(dataPath{i,2});    
    noOfImg=size(fileList,2);
    randomOrder=randperm(noOfImg,noOfImg);
    noOFTestImg=ceil(testPercent*noOfImg/100);
    fprintf('noOfImg:%d noOfTrain:%d noOfTest:%d\n',noOfImg,noOfImg-noOFTestImg,noOFTestImg);
    fprintf('Staring Train set..\n');
    % train
    for j=1:noOfImg-noOFTestImg-1
        fprintf('Train img %d/%d\n',j,noOfImg-noOFTestImg-1);        
        filename=fileList{randomOrder(j)};
        splitResult=strsplit(filename,'.');
        imgNum=splitResult{1};           
        newName=strcat(num2str(i),'_',imgNum); 
        
        % img
        fromPath=strcat(dataPath{i,1},'/',imgNum,'.png');
        toPath=strcat(saveTrainDPImg,'/',newName,'.png');
        copyfile(fromPath,toPath);
        
        % raw
        fromPath=strcat(dataPath{i,2},'/',imgNum,'.mat');
        toPath=strcat(saveTrainDPRaw,'/',newName,'.mat');
        copyfile(fromPath,toPath);
    end
    fprintf('Staring Test set..\n');
    % test
    for j=noOfImg-noOFTestImg:noOfImg
        fprintf('Test img %d/%d\n',j,noOfImg);
        filename=fileList{randomOrder(j)};
        splitResult=strsplit(filename,'.');
        imgNum=splitResult{1};           
        newName=strcat(num2str(i),'_',imgNum); 
        
        % img
        fromPath=strcat(dataPath{i,1},'/',imgNum,'.png');
        toPath=strcat(saveTestDPImg,'/',newName,'.png');
        copyfile(fromPath,toPath);
        
        % raw
        fromPath=strcat(dataPath{i,2},'/',imgNum,'.mat');
        toPath=strcat(saveTestDPRaw,'/',newName,'.mat');
        copyfile(fromPath,toPath);
    end
    
end
fprintf('Completed...\n');
