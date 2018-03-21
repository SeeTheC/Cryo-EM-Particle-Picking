% dataPath: contains of paths of data where the .mat images are present
function [dataMtx,totalRecord] = getImgDataAsDataMtx(dataPath,dim,downscaleBy)
    noOfDataDir=numel(dataPath);    
    dataMtx=[];totalRecord=0;
    for d=1:noOfDataDir
        dirPath=dataPath{d};
        [dm,recordCount]=readDatabase(dirPath,dim,downscaleBy);
        dataMtx=vertcat(dataMtx,dm);
        totalRecord=totalRecord+recordCount;
    end
end

% Reads the images from the Database and returns the dataset Mtx where each
% row is the one record.

function [dataMtx,recordCount]=readDatabase(dirpath,dim,downscaleBy)
    row=dim(1);col=dim(2);
    
    imgFolder = dir(dirpath);
    imgFolder =natsortfiles({imgFolder.name});     
    numOfImg=numel(imgFolder)-2;    
    numOfImg=10;
    dataMtx=zeros(numOfImg,(row*col));        
    for j = 1:numOfImg
            %fileName=imgFilesPerPerson(j);fileName=fileName{1};
            fileName=imgFolder(j);
            fileName=fileName{1};
            if ( strcmp(fileName,'.') || strcmp(fileName,'..'))
                continue;
            end            
            imgPath=strcat(dirpath,'/',fileName);             
            struct=load(imgPath);
            img=struct.img;   
            if downscaleBy ~= 1
                img=imresize(img,1/downscaleBy);
            end
            %img = imread(fullFilePath);
            [irow,icol] = size(img);
            vector = reshape(img,1,irow*icol);                      
            dataMtx(j,:) = vector;
    end
    recordCount=numOfImg;
    fprintf('# %d Files Read from dir %s\n',numOfImg,dirpath);
end


