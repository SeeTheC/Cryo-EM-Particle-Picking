%% Init: Config
clear all;
addpath(genpath('../../DataCorrection/'));
addpath(genpath('../'));
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
imgDir='Train_Preprocess1';
imgSub='img';
boxFile='train_bbox.csv'
%--------------------------------------------------------------------------

basepath = strcat(basepath,'/',dataset);
srcPath=strcat(basepath,'/',imgDir);
srcPath=strcat(srcPath,'/',imgSub);
boxFilePath=strcat(basepath,'/',imgDir,'/',boxFile);

dstPath=strcat(basepath,'/Train_Preprocess2_',timestamp);
mkdir(dstPath);
rotateTblFn=strcat(dstPath,'/rotate90_bbox.csv');
rotateScaleTblFn=strcat(dstPath,'/rot180Scale_bbox.csv');
fullTblFn=strcat(dstPath,'/train_bbox_1.csv');
dstPath=strcat(dstPath,'/img');
mkdir(dstPath);
fprintf('Done\n');

%% Read CSV File
fprintf('CSV file \n');
finaltable = readtable(boxFilePath);
finaltable.Properties.VariableNames={'name','x','y','h','w'};
imgTable = readBboxCsv(boxFilePath);
imgTable.Properties.VariableNames={'filename','box'};
nameCol=imgTable.filename;
nameCol=table(nameCol,'VariableNames',{'name'});
imgTable=[nameCol,imgTable];
imgTable.filename = fullfile(srcPath, imgTable.filename);
fprintf('Done\n');

%% Visualizing Dataset 
% Read one of the images.
imgNo=2183;
downscale=4;
img = imread(imgTable.filename{imgNo});
img1=imresize(img,1/downscale);
img1=double(img1-min(img1(:)));
img1=img1./max(img1(:));
bbox=imgTable.box{imgNo};
I = insertShape(img1, 'Rectangle', bbox./downscale);
figure
imshow(I,[]);
J = imrotate(I,90);
figure
imshow(J,[]);
%%

%% %% Rotate By 90 
% Rect: 2183

imgNo=2186;
downscale=4;
angle=90;
img = imread(imgTable.filename{imgNo});
H=size(img,1);W=size(img,2);
img = imrotate(img,angle);
img1=imresize(img,1/downscale);
img1=double(img1-min(img1(:)));
img1=img1./max(img1(:));
bbox=imgTable.box{imgNo}
cx=H/2;cy=W/2;

rand=((angle)*pi)/180;
R = [cos(rand),-sin(rand); sin(rand), cos(rand) ];
cR=R*[cx,cy]';
Rcx=cR(1);Rcy=cR(2);
for i=1:size(bbox,1)
    x=bbox(i,2)+108-cx;y=bbox(i,1)+108-cy;
    v=[x;y];vR=R*v;        
    x=cy+vR(1);y=vR(2)+cx; % for rectangle
    fprintf('x:%d y:%d\n',x,y);
    bbox(i,1)=y-108;bbox(i,2)=x-108;
    bbox(i,3)=108*2;bbox(i,4)=108*2;
end
bbox
I = insertShape(img1, 'Rectangle', bbox./downscale);
figure
imshow(I,[]);
%% Rototate ALL By 90
fprintf('Rotating Image..\n');
angle=90;
rand=((angle)*pi)/180;
R=[cos(rand), -sin(rand);sin(rand),cos(rand)];
downscale=4;

noOfImage=size(imgTable,1);
rotateTbl=cell(0,5);
rowNum=1;
for imgNo=1:noOfImage
    img = imread(imgTable.filename{imgNo});
    [H,W]=size(img);    
    img = imrotate(img,angle);
    dfn=strcat('rot90_',imgTable.name{imgNo});
    dfpath=strcat(dstPath,'/',dfn);
    cx=H/2;cy=W/2;
    bbox=imgTable.box{imgNo};
    for i=1:size(bbox,1)
        halfBoxH=bbox(i,4)/2;halfBoxW=bbox(i,3)/2;    
        x=bbox(i,2)+halfBoxH-cx;y=bbox(i,1)+halfBoxW-cy;
        v=[x;y];vR=R*v;
        x=cy+vR(1)-halfBoxH;y=vR(2)+cx-halfBoxW;
        bbox(i,1)=y;bbox(i,2)=x;
        rotateTbl(rowNum,:)={dfn,double(x),double(y),halfBoxH*2,halfBoxW*2};
        rowNum=rowNum+1;
    end 
    imwrite(img,dfpath);
    % View
    %{
    img1=imresize(img,1/downscale);
    img1=double(img1-min(img1(:)));
    img1=img1./max(img1(:));
    I = insertShape(img1, 'Rectangle', bbox./downscale);
    figure
    imshow(I,[]);
    %}
end

rotateTbl=cell2table(rotateTbl);
rotateTbl.Properties.VariableNames={'name','x','y','h','w'};
writetable(rotateTbl,rotateTblFn);
completeTbl=[finaltable;rotateTbl];
writetable(completeTbl,fullTblFn);
fprintf('Done');
% Saving Result
%%

%% Rototate ALL By 180 & rescale
fprintf('Rotating 180 & Scaling Image..\n');
angle=180;
rand=((angle)*pi)/180;
R=[cos(rand), -sin(rand);sin(rand),cos(rand)];
downscale=4;
newH=280;newW=250;
noOfImage=size(imgTable,1);
rotateScaleTbl=cell(0,5);
rowNum=1;
for imgNo=1:noOfImage
    img = imread(imgTable.filename{imgNo});
    [H,W]=size(img);
    img = imrotate(img,angle);
    dfn=strcat('rot180Scale_',imgTable.name{imgNo});
    dfpath=strcat(dstPath,'/',dfn);    
    cx=H/2;cy=W/2;
    bbox=imgTable.box{imgNo};
    for i=1:size(bbox,1)
        halfBoxH=bbox(i,4)/2;halfBoxW=bbox(i,3)/2;    
        x=bbox(i,2)+halfBoxH-cx;y=bbox(i,1)+halfBoxW-cy;
        v=[x;y];vR=R*v;
        x=cx+vR(1)-(newH/2);y=vR(2)+cy-(newW/2);
        if(x<1 || y < 1 || x+newH>H || y+newW>W)
            fprintf('Range is Greater.. x:%d y:%d\n',x,y);
            continue;
        end
        bbox(i,1)=y;bbox(i,2)=x;bbox(i,3)=newW;bbox(i,4)=newH;        
        rotateScaleTbl(rowNum,:)={dfn,double(x),double(y),newH,newW};
        rowNum=rowNum+1;
    end 
    imwrite(img,dfpath);
    % View
    %{
    img1=imresize(img,1/downscale);
    img1=double(img1-min(img1(:)));
    img1=img1./max(img1(:));
    I = insertShape(img1, 'Rectangle', bbox./downscale);
    figure
    imshow(I,[]);
    %}
end

% Saving Result
rotateScaleTbl=cell2table(rotateScaleTbl);
rotateScaleTbl.Properties.VariableNames={'name','x','y','h','w'};
writetable(rotateScaleTbl,rotateScaleTblFn);
completeTbl=[completeTbl;rotateScaleTbl];
writetable(completeTbl,fullTblFn);
fprintf('Done\n');

%%
