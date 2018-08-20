%% Init
clear all;
addpath(genpath('../'));
addpath(genpath('../../MapFileReader/'));
addpath(genpath('../../EM-Micrograph/script'));
server = 2;
if server==1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                              
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

%------------------------------[Real Dataset: server:2]------------------------------------
    collageDir='collage';   
    modelType=ModelType.RandomForest;   
    model='model_1-2-4-8_18000';        
    maxCollageSize=[5000,5000];    
    probThershold=0.6;
    
    %modelType=ModelType.CompactSVM;       
    %model='model_1-2-4-8_2000x2000';      
    %maxCollageSize=[2000,2000];
    %probThershold=0.62;
    
    %model='model_1-2-4-8';
    
    cellH=216; cellW=216;
    supressBoxSize=[216,216];   
    scaleModel=4;
    downscaleModel=8;
    %collageNum='14sep05c_00024sq_00003hl_00002es_c'; 
    %collageNum='14sep05c_c_00007gr_00021sq_00016hl_00003es_c';
    %collageNumDir='14sep05c_c_00007gr_00021sq_00016hl_00003es_c_tr_18000_maxHW5000x5000';
    
    %14sep05c_c_00007gr_00021sq_00017hl_00002es_c
    collageNum='14sep05c_c_00007gr_00021sq_00017hl_00002es_c';
    collageNumDir='14sep05c_c_00007gr_00021sq_00017hl_00002es_c_tr_18000_maxHW5000x5000';
    
    basepath=strcat(basepath,'/_data-proj-10025','v.10'); % img dimension: [216,216] 
    coordMetadataPath=strcat(basepath,'/10025/','run1_shiny_mp007_data_dotstar.txt.star');    
%------------------------------[END Real Dataset: server:2]------------------------------------
   
mt='';
if modelType==ModelType.CompactSVM   
    mt='svm'; 
elseif modelType==ModelType.RandomForest
    mt='ramdomForest';
elseif modelType==ModelType.DecisionTree
    mt='decisionTree';
end

%trainPath=strcat(basepath,'/train','/',collageDir);
testPath=strcat(basepath,'/test','/',collageDir);
testCollageRawPath= strcat(testPath,'/processed_img/',mt);
%testCollageRawPath= strcat(testPath,'/processed_img/ramdomForest');
testCollageRawPath= strcat(testCollageRawPath,'/',collageNumDir);
testCollageRawPath=strcat(testCollageRawPath,'/',model,'/model-',num2str(scaleModel));
name=strcat(testCollageRawPath,'/',collageNum,'.mat');
struct=load(name);
scoreCollage=struct.outImg;

if server==2
    originalCollageName= strcat(testPath,'/raw_img/',collageNum,'.mrc');  
    [orgCollage,~,~,~,~]=ReadMRC(originalCollageName);
    orgCollage=orgCollage(1:maxCollageSize(1),1:maxCollageSize(2));    
else
    originalCollageName=strcat(testPath,'/raw_img/',collage,'.mat');
    struct=load(originalCollageName);
    orgCollage=struct.img;
    orgCollage=orgCollage(1:maxCollageSize(1),1:maxCollageSize(2));
end

if(scaleModel>1)
    collage=imresize(orgCollage,1/downscaleModel);
    cellH=cellH/downscaleModel; cellW=cellW/downscaleModel;
    supressBoxSize=supressBoxSize./downscaleModel;
else
    collage=orgCollage;
end    
%collage=imresize(collage,(1/8));
[H,W]=size(collage);

% Fetching True cordinates
[trueKnownCoord,keyword]=getRelionCoordinate(collageNum,coordMetadataPath);

fprintf('Init Done.\n');
%% Finding  location using maxmial suppression
%probThershold=0.4;
boxSize=[cellH,cellW];
[cX,cY]=findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,1000);
noOfRect=size(cX,1);
fprintf('noOfRect:%d .Done...\n',noOfRect);
%% Config & Mark Center
drawingConfig.originalMg=orgCollage;
drawingConfig.visualDownsample=downscaleModel;  
%drawingConfig.downscaleModel=downscaleModel;
drawingConfig.predictedLoc=[cX*downscaleModel,cY*downscaleModel];
drawingConfig.trueKnownLoc=trueKnownCoord;
drawingConfig.savepath='.';
drawingConfig.maxCollageSize=maxCollageSize;
% MarkCenter
[predImg,predTrueImg] = markCenterParticle(drawingConfig);
%% Drawing box
fprintf('Drawing Box...\n');
%img=collage1026506

downsample=1;
img=imresize(collage,1/downsample);
img=img-min(img(:));
img=img/max(img(:));

lineWidth=2;    markerSize=3;    predictColor='red';

% mark center
% predicted center    
for r= 1:noOfRect
    cx=cX(r)/downsample;cy=cY(r)/downsample;
    img=insertThickMarker(img,[cx,cy],markerSize,lineWidth,predictColor);
end
fprintf('Done.\n');
%figure,imshow(img,[]);
%title({'\fontsize{10}{\color{magenta}RandomForest 2000x2000 Micrograph}','\fontsize{10}{\color{red}[Downsampled by 8 for better visualization]}'});
% Save Center mark
imwrite(img,'Predicted.png');
% Drawing True Center
fprintf('Drawing True Center...\n');
img1=img;
lineWidth=2;    markerSize=1;    predictColor='green';
n=size(trueKnownCoord,1);
%maxCollageSize
for idx=1:n
    row=trueKnownCoord(idx,:);
    cx=row.x/downscaleModel;cy=row.y/downscaleModel;
    if(cx>maxCollageSize(1) || cy >maxCollageSize(2))
        continue;
    end
    cx=cx/downsample;cy=cy/downsample;
    img1=insertThickMarker(img1,[cx,cy],markerSize,lineWidth,predictColor);      
end

fprintf('Done.\n');
% Show result
figure,
imshow(img1,[]),impixelinfo;
title({'\fontsize{10}{\color{magenta} SVM: Green->true & Re->predicted 2000x2000 Micrograph}','\fontsize{10}{\color{red}[Downsampled by 8 for better visualization]}'});
%title({'\fontsize{10}{\color{magenta} RF: Green->true & Re->predicted 2000x2000 Micrograph}','\fontsize{10}{\color{red}[Downsampled by 8 for better visualization]}'});

% Save Center mark
imwrite(img1,'True_and_Predicted.png');
%% Draw rectangle
fprintf('Drawing rectangle...\n');
fh = figure;
imshow(img1);
hold on;
for r= 1:noOfRect
    cx=cX(r);cy=cY(r);
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
    
end
%% Save/show
%frm = getframe( fh ); %// get the image+rectangle
%imwrite(frm.cdata,'boxImage.png');
%hold off;
figure,
imshow(img1);
fprintf('Done.\n');
%%