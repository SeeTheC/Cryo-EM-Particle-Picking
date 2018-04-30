% dataPath: contains of paths of data where the .mat images are present
function [dataMtx,totalRecord] = getImgDataAsDataMtx(dataPath,dim,downscaleBy,maxNumberSample)
    noOfDataDir=numel(dataPath);    
    dataMtx=[];totalRecord=0;
    for d=1:noOfDataDir
        dirPath=dataPath{d};
        [dm,recordCount]=readDatabase(dirPath,dim,downscaleBy,maxNumberSample);
        dataMtx=vertcat(dataMtx,dm);
        totalRecord=totalRecord+recordCount;
    end
end

% Reads the images from the Database and returns the dataset Mtx where each
% row is the one record.

function [dataMtx,recordCount]=readDatabase(dirpath,dim,downscaleBy,maxNumberSample)
    fprintf('Reading dataset...\n');
    fprintf('dataset:%s\n',dirpath);
    
    row=dim(1);col=dim(2);
    
    imgFolder = dir(dirpath);
    imgFolder=natsortfiles({imgFolder.name});
    % removing  file "." and ".."
    imgFolder=imgFolder(3:end);
    totalNumOfImg=numel(imgFolder);       
    numOfImg=min(maxNumberSample,totalNumOfImg);  
    randomOrder=randperm(totalNumOfImg,numOfImg);
    imgFolder=imgFolder(randomOrder);
    dataMtx=zeros(numOfImg,(row*col));      


    fprintf('Totalfiles:%d\n',totalNumOfImg);
    fprintf('Taking files:%d randomly\n',numOfImg);
    

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
            %fprintf('%d) %s : %d-%d\n',j, fileName,irow,icol);
            vector = reshape(img,1,irow*icol);                      
            dataMtx(j,:) = vector;
    end
    recordCount=numOfImg;
    fprintf('# %d Files Read from dir %s\n',numOfImg,dirpath);
end


