%% Creates the GRID collage from dataset
fprintf('Creating Collage for Train and Test +ve Data...\n');
addpath('../DataCorrection/');
%% Init

timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
trainDP = strcat(basepath,'/_data-Y,Z','v.10','/train');
testDP = strcat(basepath,'/_data-Y,Z','v.10','/test');

trainDPRaw=strcat(trainDP,'/raw_img');
testDPRaw=strcat(testDP,'/raw_img');


saveTrainCollagePath=strcat(trainDP,'/collage_',timestamp);
saveTrainCollageDPImg = strcat(saveTrainCollagePath,'/img');
saveTrainCollageDPRaw = strcat(saveTrainCollagePath,'/raw_img');

saveTestCollagePath=strcat(testDP,'/collage_',timestamp);
saveTestCollageDPImg = strcat(saveTestCollagePath,'/img');
saveTestCollageDPRaw = strcat(saveTestCollagePath,'/raw_img');

% Data dir
dataPath{1,1}=trainDPRaw;
dataPath{1,2}=saveTrainCollagePath;
dataPath{1,3}=saveTrainCollageDPImg;
dataPath{1,4}=saveTrainCollageDPRaw;
dataPath{1,5}=getDirFilesName(dataPath{1,1});
dataPath{1,6}=size(dataPath{1,5},2);

dataPath{2,1}=testDPRaw;
dataPath{2,2}=saveTestCollagePath;
dataPath{2,3}=saveTestCollageDPImg;
dataPath{2,4}=saveTestCollageDPRaw;
dataPath{2,5}=getDirFilesName(dataPath{2,1});
dataPath{2,6}=size(dataPath{2,5},2);


% Per cell one image
cellH=333; cellW=333;
gridRow=10; gridCol=10;
%gridRow=2; gridCol=2;

noOfCollage=3;
noOfDataFolder=size(dataPath,1);

% size of original image
%% Create Dir
for i=1:noOfDataFolder
    mkdir(dataPath{i,3});
    mkdir(dataPath{i,4});
end
%%  Create Collage

 
for dir=1:noOfDataFolder
     % Creating a file
    savepath=dataPath{dir,2};
    fileNamelist=dataPath{dir,5};
    perDataFolderImgCount=dataPath{dir,6};
    
    fid = fopen(strcat(savepath,'/0_info.txt'), 'a+');
    fprintf(fid, '# Angles and Number Format Matrix');
    fprintf(fid, '\n# Matrix are shown in vector form where indexing is from top to bottom and left to right, similar to matlab format');

    for i=1:noOfCollage          
        randImgNum=randi([1,perDataFolderImgCount],gridRow,gridCol);
        collage=zeros(cellH*gridRow,cellW*gridCol);    
        for r=1:gridRow
            x1=(r-1)*cellH+1; x2=(r-1)*cellH+cellH;
            for c=1:gridCol
                y1=(c-1)*cellW+1; y2=(c-1)*cellW+cellW;                       
                imgNum=randImgNum(r,c);
                filename=fileNamelist(imgNum);
                filename=filename{1};
                imgPath=strcat(dataPath{dir,1},'/',filename);
                struct=load(imgPath);
                img=struct.img;                   
                collage(x1:x2,y1:y2)=img;  
            end        
        end

        % writing info
        fprintf(fid, '\n# -----------------------------------\n');            
        fprintf(fid, 'Collage= %d \n',i);
        fprintf(fid, 'Folder = ');            
        fprintf(fid, '\nImageNumber  =');
        fprintf(fid, ' %d',randImgNum);
        imwrite(uint8(collage),strcat(dataPath{dir,3},'/',num2str(i),'.jpg'));
        % saveing raw img
        img=collage;
        save(strcat(dataPath{dir,4},'/',num2str(i),'.mat'),'img');
    end
end
fprintf('Completed...\n');
%%
%figure('name','collage');
%imshow(uint8(collage));
