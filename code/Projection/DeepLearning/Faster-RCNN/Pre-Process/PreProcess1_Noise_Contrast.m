%% Init: Config
clear all;
addpath(genpath('../../DataCorrection/'));
fprintf('Initializing..\n');
server=2;
if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end 

timestamp=datestr(now,'dd-mm-yyyy_HH-MM-SS');
timestamp=strcat('ts_',timestamp);

%----------------------------[Config:1]--------------------------------------
dataset='_dl-proj-10025v.10_mghw_1000';
imgDir='Train';
imgSub='img';
%--------------------------------------------------------------------------

basepath = strcat(basepath,'/',dataset);
srcPath=strcat(basepath,'/Train');
srcPath=strcat(srcPath,'/img');

dstPath=strcat(basepath,'/Train_Preprocess1_',timestamp);
mkdir(dstPath);
dstPath=strcat(dstPath,'/img');
mkdir(dstPath);
fprintf('Done\n');

%% Read Img files
filename=getDirFilesName(srcPath);
noOfMg=numel(filename);
fprintf('** Number of Image to process:%d\n',noOfMg);

%% Process image
fprintf('Procession img for NOISE and Contrast....\n');    
for i=1:noOfMg
    fn=filename{i};
    fprintf('Procession img %d: %s\n',i,fn);
    sfpath=strcat(srcPath,'/',fn);
    dfpath=strcat(dstPath,'/',fn);
    img=imread(sfpath);
    %img2 = wiener2(adapthisteq(imcomplement(img)),[5 5]);
    img2 = wiener2(histeq(imcomplement(img)),[5 5]);   
    %img2 = wiener2(adapthisteq(imcomplement(img),'clipLimit',0.1,'Distribution','rayleigh'),[5 5]);
    imwrite(img2,dfpath);
end

fprintf('Done\n');




