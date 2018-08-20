%% INIT
clear all;
addpath('../../DataCorrection/');
addpath(genpath('../../MapFileReader/'));
addpath(genpath('../../Classification'));

server=2;

if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end  
timestamp=datestr(now,'dd-mm-yyyy_HH:MM:SS');   
%----------------------------[Config]-------------------------------
dataset='_dl-proj-10025v.10_mghw_1000';
%-------------------------------------------------------------------
basepath=strcat(basepath,'/',dataset);
trainPath=strcat(basepath,'/Train');
trainImgPath=strcat(trainPath,'/img');
trainBboxPath=strcat(trainPath,'/train_bbox.csv');
saveTrainImgPath=strcat(basepath,'/verify_ts_',timestamp);
mkdir(saveTrainImgPath);
fprintf('Init Done\n');

%% Draw box;

[T,csv]= readBboxCsv(trainBboxPath);
sortedT = sortrows(T,[1]);
prevfile='';
n=size(sortedT,1);
fprintf('Number of Img:%d\n',n);
downscale=1;
for i=1:10%n
    row=sortedT(i,:);
    name=row{1,1}{1};
    bbox=row{1,2}{1};
    bbox=bbox./downscale;
    fprintf('* Processing: %s\n',name);
    if(strcmp(prevfile,name))
       rectangle('Position',[bbox(2),bbox(1),bbox(4),bbox(3)],'EdgeColor', 'r','LineWidth', 1,'LineStyle','-');    
    else
       fprintf('-->New MG\n');
       f=strcat(trainImgPath,'/',name);
       img=imread(f);
       if(downscale==1)
            imshow(img,[]),
       else
            imshow(imresize(img,1/downscale),[]),
       end
       hold on,
       pause(2);
       rectangle('Position',[bbox(2),bbox(1),bbox(4),bbox(3)],'EdgeColor', 'r','LineWidth', 1,'LineStyle','-');    
    end
    prevfile=name;
    saveas(gcf,strcat(saveTrainImgPath,'/',name));    
end
fprintf('Done.\n');


