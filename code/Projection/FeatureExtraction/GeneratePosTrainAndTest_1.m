% Seperate +ve positive images into train and test data
fprintf('Seperating +ve positive images into train and test data...\n');
%% Init 
server=0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

% +v images
dataPath{1,1}=strcat(basepath,'/Y/img');
dataPath{1,2}=strcat(basepath,'/Y/raw_img');
dataPath{2,1}=strcat(basepath,'/Z/img');
dataPath{2,2}=strcat(basepath,'/Z/raw_img');

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
saveTrainDP = strcat(basepath,'/_data-Y,Z','v.10','/train');
saveTestDP = strcat(basepath,'/_data-Y,Z','v.10','/test');

saveTrainDPImg=strcat(saveTrainDP,'/img');
saveTrainDPRaw=strcat(saveTrainDP,'/raw_img');

saveTestDPImg=strcat(saveTestDP,'/img');
saveTestDPRaw=strcat(saveTestDP,'/raw_img');

mkdir(saveTrainDP);
mkdir(saveTestDP);

mkdir(saveTrainDPImg);
mkdir(saveTrainDPRaw);
mkdir(saveTestDPImg);
mkdir(saveTestDPRaw);


% Test Data Percentage
testPercent=25; % i.e 25 %
%% Random Fetch Train and Test data
addpath('../DataCorrection/');
for i=1:size(dataPath,1)
    fileList=getDirFilesName(dataPath{i});
    noOfImg=size(fileList,2);
    randomOrder=randperm(noOfImg,noOfImg);
    noOFTestImg=ceil(25*noOfImg/100);
    % train
    for j=1:noOfImg-noOFTestImg-1
        filename=fileList{randomOrder(j)};
        splitResult=strsplit(filename,'.');
        imgNum=splitResult{1};           
        newName=strcat(num2str(i),'_',imgNum); 
        
        % img
        fromPath=strcat(dataPath{i,1},'/',imgNum,'.jpg');
        toPath=strcat(saveTrainDPImg,'/',newName,'.jpg');
        copyfile(fromPath,toPath);
        
        % raw
        fromPath=strcat(dataPath{i,2},'/',imgNum,'.mat');
        toPath=strcat(saveTrainDPRaw,'/',newName,'.mat');
        copyfile(fromPath,toPath);
    end
    % test
    for j=noOfImg-noOFTestImg:noOfImg
        
        filename=fileList{randomOrder(j)};
        splitResult=strsplit(filename,'.');
        imgNum=splitResult{1};           
        newName=strcat(num2str(i),'_',imgNum); 
        
        % img
        fromPath=strcat(dataPath{i,1},'/',imgNum,'.jpg');
        toPath=strcat(saveTestDPImg,'/',newName,'.jpg');
        copyfile(fromPath,toPath);
        
        % raw
        fromPath=strcat(dataPath{i,2},'/',imgNum,'.mat');
        toPath=strcat(saveTestDPRaw,'/',newName,'.mat');
        copyfile(fromPath,toPath);
    end
    
end
fprintf('Completed...\n');
