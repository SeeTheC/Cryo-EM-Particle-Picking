% Seperate +ve positive images into train and test data
fprintf('Creating Noisy +ve positive images for train and test data\n');
addpath('../DataCorrection/');
%% Init 
server=0
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

% +v images
% Example:
%basepath = strcat(basepath,'/_data-Y,Z','v.10','/train');

% ------------------[Config]---------------------
%basepath = strcat(basepath,'/_data-Y,Z','v.10');
basepath=strcat(basepath,'/_data-proj-5693','v.20');background=30;
%basepath=strcat(basepath,'/_data-proj-2211','v.10');background=0.1;
%basepath=strcat(basepath,'/_data-proj-5689','v.10');background=0.065;
%basepath=strcat(basepath,'/_data-proj-5762','v.10');background=0.1;

maxNumSample=2; % defalut "Inf"
poissonDownScaleIntesity=2; % used in poisson noise creation 
currentBackgroundIntensity=background; % used in poisson noise creation
% ------------------------------------------
trainDP = strcat(basepath,'/train');
testDP = strcat(basepath,'/test');

dataPath{1,1}=strcat(trainDP,'/img');
dataPath{1,2}=strcat(trainDP,'/raw_img');

dataPath{2,1}=strcat(testDP,'/img');
dataPath{2,2}=strcat(testDP,'/raw_img');

dataPath{3,1}=strcat(trainDP,'/collage1_6x6','/img');
dataPath{3,2}=strcat(trainDP,'/collage1_6x6','/raw_img');

dataPath{4,1}=strcat(testDP,'/collage1_6x6','/img');
dataPath{4,2}=strcat(testDP,'/collage1_6x6','/raw_img');

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
noisyPath   = strcat(basepath,'/Noisy_downscale',num2str(poissonDownScaleIntesity),'_t',timestamp);
saveTrainDP = strcat(noisyPath,'/train');
saveTestDP  = strcat(noisyPath,'/test');

saveDP{1,1}=strcat(saveTrainDP,'/img');
saveDP{1,2}=strcat(saveTrainDP,'/raw_img');
saveDP{1,3}=strcat(saveTrainDP,'/noise_info.txt');

saveDP{2,1}=strcat(saveTestDP,'/img');
saveDP{2,2}=strcat(saveTestDP,'/raw_img');
saveDP{2,3}=strcat(saveTestDP,'/noise_info.txt');

saveDP{3,1}=strcat(saveTrainDP,'/collage1_6x6','/img');
saveDP{3,2}=strcat(saveTrainDP,'/collage1_6x6','/raw_img');
SaveDP{3,3}=strcat(saveTrainDP,'/collage1_6x6','/noise_info.txt');

saveDP{4,1}=strcat(saveTestDP,'/collage1_6x6','/img');
saveDP{4,2}=strcat(saveTestDP,'/collage1_6x6','/raw_img');
saveDP{4,3}=strcat(saveTestDP,'/collage1_6x6','/noise_info.txt');


mkdir(saveTrainDP);
mkdir(saveTestDP);

for i=1:size(saveDP,1);
    mkdir(saveDP{i,1});
    mkdir(saveDP{i,2});
end

%% Generate for Noisy  data
fprintf('Generate for Noisy data..\n');

for i=1:size(dataPath,1)
    fprintf('--------------------[Datapath:%d]------------------\n',i);
    fileList=getDirFilesName(dataPath{i});
    noOfImg=size(fileList,2);
    noOfImg=min(maxNumSample,noOfImg);    
    randomOrder=randperm(noOfImg,noOfImg);  
    fid = fopen(saveDP{i,3}, 'w+');
    fprintf(fid,'img#\ttotal_int_val\tafter_down_scale\tdownscale_by');
    
    % train
    for j=1:noOfImg
        filename=fileList{randomOrder(j)};
        splitResult=strsplit(filename,'.');
        imgNum=splitResult{1};           
        newName=strcat(imgNum);         
        fromPath=strcat(dataPath{i,2},'/',imgNum,'.mat');
        
        struct=load(fromPath);
        img=struct.img;
                
        [noisyImg,tiv,dtiv]=addPoissonNoise(img,poissonDownScaleIntesity,currentBackgroundIntensity);
        fprintf(fid,'%d\t%f\t%f\t%d',j,tiv,dtiv,poissonDownScaleIntesity);
        % img
        img=noisyImg/max(noisyImg(:));                        
        %imshow(img)        
        toPath=strcat(saveDP{i,1},'/',newName,'.jpg');
        imwrite(im2double(img),toPath);
        % raw
        img=noisyImg;
        toPath=strcat(saveDP{i,2},'/',newName,'.mat');
        save(toPath,'img');
    end    
    fclose(fid);
    
end
fprintf('Completed...\n');

