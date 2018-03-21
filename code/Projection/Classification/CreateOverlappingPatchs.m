%% 
server = 0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
basepath=strcat(basepath,'/_data-Y,Z','v.10');

trainPath=strcat(basepath,'/train');
testPath=strcat(basepath,'/test');

collageNum='1'
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/',collageNum,'.mat');
savedImgDir= strcat(testPath,'/collage1_6x6','/raw_img/',collageNum,'_overlapseg');
mkdir(savedImgDir);
%% Reading PCA
%workinfDirPath=  strcat(basepath,'/pca_data/train/');
%svm_pcaCoeff=dlmread(strcat(workinfDirPath,'/pca_coeff.txt'));
%svm_pcamu=dlmread(strcat(workinfDirPath,'/data_mean.txt'));
%svm_pcamu=svm_pcamu';

%% Load Collage
struct=load(testCollagePath);
collage=struct.img;
%%
% patchH == cellH of collage and patchW == cellW of collage
patchH=333;patchW=333;
[H,W]=size(collage);
patchDim=[patchH,patchW];
halfPatchH=patchH/2;halfPatchW=patchW/2;
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
%% Generating overlap Segment
% For j=1:2000 it will take 2 mins to num
tic
for i= hStartIdx:hStartIdx %hEndIdx                 
    fprintf('i=%d\n',i);
    for j=wStartIdx:wStartIdx+ 1000 % wEndIdx   
        fprintf('j=%d\n',j);
        [x1,x2,y1,y2]=getPatchCoordinat(i,j,patchDim);
        img=collage(x1:x2,y1:y2);
        name=strcat(num2str(i),'_',num2str(j),'_',num2str(x1),':',num2str(x2),':',num2str(y1),':',num2str(y2),'.mat');
        save(strcat(savedImgDir,'/',name),'img');
    end
end
toc
%% Saveing Image as PCA
