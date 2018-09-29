%% Parse all file
clear all;
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
addpath(genpath('../DataCorrection/'));
addpath(genpath('script/'));

%% INIT
server=2;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server==3
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/mtp-data/RealDataset/10012';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset/10012';
end

mrcBPath=strcat(basepath,'/raw_img');
markingPath=strcat(basepath,'/box');
savePath=strcat(basepath);

%% Process

% Reading Files Name
filename=getDirFilesName(mrcBPath,'mrc');
noOfMg=numel(filename);
fprintf('** Number of Micrograph to process:%d\n',noOfMg);

%% Process each Micrograph
for i=1:1%noOfMg
    fullfn=filename{i};
    fprintf('Processing Mg(%d/%d): %s\n',i,noOfMg,fullfn);
    fn=split(fullfn,'.');
    fn=fn{1};
    file=strcat(mrcBPath,'/',fullfn);
    [mg,s,mi,ma,av]=ReadMRC(file);
    %micrograph=mean(img,3);
    %save(strcat(savePath,'/',fn,'.mat'),'micrograph');
end    
fprintf('Done\n');
%% Load TESTING
%l=strcat(savePath,'/',fn,'.mat');
%mg=load(l);
%mg=mg.micrograph;
%% TESTING MARKING
markingFile=strcat(markingPath,'/','BGal_000010.box');
tbl=getAllCoordinate(markingFile);
%% TEMP tbl
tbl={[4441,546 ];[3840,874 ];[1610,1229];[4099,1238];[3542,1255];[6755,1448];[3435,1792];[3641,1797];[6827,2629];[2129,2776];[5701,2860];[6684,3298];[3361,3320];[4047,3422]}
tbl=cell2table(tbl);
%%
downscale=8;
img=imresize(double(mg),1/downscale);
img=img/max(img(:));
lineWidth=1;predictColor='red';
%mark center
% predicted center    
for r= 1:size(tbl,1)
    cx=round(tbl{r,:}(1)/downscale);cy=round(tbl{r,:}(2)/downscale);
    fprintf('Particle: i:%d x:%d y:%d\n',r,cx,cy);
    markSize=1;
    img=insertMarker(img,[cy,cx],'x','color',predictColor,'size',markSize);    
    for w=1:lineWidth
        img=insertMarker(img,[cy-w,cx],'x','color',predictColor,'size',markSize); 
        img=insertMarker(img,[cy,cx-w],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy+w,cx],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy,cx+w],'x','color',predictColor,'size',markSize);    

    end
end
imshow(img);
fprintf('Done\n');

%% Draw rectangle
fprintf('Drawing rectangle...\n');
downscale=12;
img1=imresize(double(mg),1/downscale);
img1=img1/max(img1(:));
fh = figure;
imshow(img1);
hold on;
boxSize=round([216,216]./downscale);
for r= 1:10%noOfRect
    row=tbl(r,:);
    cx=round((row.x)./downscale);cy=round((row.y)./downscale);
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
    
end

%% Creating common partice marking for All micrograph

%%
% Reading Files Name
filename=getDirFilesName(markingPath,'box');
noOfStar=numel(filename);
fprintf('** Number of Particle Files to process:%d\n',noOfStar);

finalTable=cell2table(cell(0,3));
finalTable.Properties.VariableNames={'name','x','y'};
for i=1:noOfStar
    file=filename{i};
    temp=split(file,'.box');
    name=strcat(temp{1},'.mrc');    
    fprintf('--Processing File-%d : %s\n',i,name);
    markingFile=strcat(markingPath,'/',file);
    tbl=getAllCoordinate(markingFile);
    noOfParticles=height(tbl);
    fprintf('No of Paticles:%d\n',noOfParticles);
    nameCol=cell(noOfParticles,1);
    nameCol(:)={name};
    tmpTbl=[nameCol,tbl];
    tmpTbl.Properties.VariableNames={'name','x','y'};
    finalTable=[finalTable;tmpTbl];
    %filter: finalTable(ismember(finalTable.name,{'aa'}),:)
end
fprintf('Saving table..');
writetable(finalTable,strcat(savePath,'/','relion_particles.csv'));
fprintf('Done.\n');

%%
markingFile=strcat(mrcBPath,'/','part1_001_autopick.star');
tbl=getAllCoordinate(markingFile)

