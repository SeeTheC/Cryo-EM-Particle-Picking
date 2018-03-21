%% ----------------------------------------------------------
%% NOT IN USED. REPLACED BY "genFeaturePCAEncoding"
%% ---------------------------------------------------------

%% Using PCA for encoding the image i.e reduction of the dimension of image

%% Init 
server = 0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end
% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE

basepath=strcat(basepath,'/_data-Y,Z','v.10');
% train images
trainDataPath{1}=strcat(basepath,'/train/raw_img');
trainNegDataPath{1}=strcat(basepath,'/train/NegImg/raw_img');
saveDataTrainPath=strcat(basepath,'/train');
savePCATrainPath=strcat(basepath,'/pca_data/train');

% test
testDataPath{1}=strcat(basepath,'/test/raw_img');
testNegDataPath{1}=strcat(basepath,'/test/NegImg/raw_img');
saveDataTestPath=strcat(basepath,'/test');
savePCATestPath=strcat(basepath,'/pca_data/test');

%image dimension
imgHeight=333;imgWidth=333;
%% 1. Fetch Train Data Images
[dataMtx,totalRecord]=getImgDataAsDataMtx(trainDataPath,[imgHeight,imgWidth]);

%% 1.1 Finding PCA and Encoding Image Vectors
fprintf('finding PCA...');
[coeff,score,latent,tsquared,explained,mu]=pca(dataMtx);
fprintf('Done\n');
fprintf('Coeff Dim: %dx%d \n',size(coeff,1),size(coeff,2));
fprintf('mu Dim: %dx%d \n',size(mu,1),size(mu,2));
fprintf('Data Coeff Dim: %dx%d \n',size(score,1),size(score,2));

%% 1.2 Save +ve data to file
fprintf('Saving Data...\n');
saveDataPath = saveDataTrainPath;
savePCAPath = savePCATrainPath;

mkdir(saveDataPath);
dlmwrite(strcat(saveDataPath,'/positive_data.txt'),dataMtx);
% Adding classification lable
y=zeros(size(dataMtx,1),1);
y(:)=1;dataMtx=horzcat(dataMtx,y);
dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx);

mkdir(savePCAPath);
dlmwrite(strcat(savePCAPath,'/pca_coeff.txt'),coeff);
dlmwrite(strcat(savePCAPath,'/data_coeff.txt'),score);
dlmwrite(strcat(savePCAPath,'/data_mean.txt'),mu);

% Adding classification lable
y=zeros(size(score,1),1);
y(:)=1;score=horzcat(score,y);
dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),score);

clear dataMtx;
clear score;
clear latent;
clear latent;
clear explained;
%clear coeff;
%clear mu;

fprintf('Done\n');
%%
%dlmwrite(strcat(saveDataPath,'/complete_data.txt'), dataMtx, 'delimiter', ',', 'precision', 6);
%csvwrite(strcat(saveDataPath,'/complete_data.txt'), dataMtx');
%save(strcat(saveDataPath,'/complete_data.txt'), 'dataMtx');
%% 2. Dimensionality Reduction of -ve sample using pca_coeff of +ve sample

%a=load(strcat(saveDataPath,'/complete_data.txt'));
%coeff1=dlmread(strcat(savePCAPath,'/pca_coeff.txt'));
%a=dlmread(strcat(saveDataPath,'/complete_data.txt'),'\t');
%a=csvread(strcat(saveDataPath,'/complete_data.txt'));

%mu=dlmread(strcat(savePCAPath,'/data_mean.txt'));
%coeff=coeff';mu=mu';

%% 1.3 Fetch -ve Data Images

[dataMtx,totalRecord]=getImgDataAsDataMtx(trainNegDataPath,[imgHeight,imgWidth]);

% Finding -ve Data Eigen Coeffient 
negData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;
%% 1.4 Save on to the file
saveDataPath = saveDataTrainPath;
savePCAPath = savePCATrainPath;

dlmwrite(strcat(saveDataPath,'/negative_data.txt'),dataMtx);
dlmwrite(strcat(savePCAPath,'/negdata_coeff.txt'),negData_coeff);

% Adding classification lable
y=zeros(size(dataMtx,1),1);
y(:)=-1;dataMtx=horzcat(dataMtx,y);
dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx,'-append');

y=zeros(size(negData_coeff,1),1);
y(:)=-1;negData_coeff=horzcat(negData_coeff,y);
dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),negData_coeff,'-append');

clear dataMtx;
clear negData_coeff;
%% 2. TEST DATA
fprintf('Finding eigen coeff for Negative value ... \n');

%% 2.1 Reading Test Data and Finding its eigen coeff

[dataMtx,totalRecord]=getImgDataAsDataMtx(testDataPath,[imgHeight,imgWidth]);

% Finding -ve Data Eigen Coeffient 
posData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;

%% 2.2 Save result
saveDataPath = saveDataTestPath;
savePCAPath = savePCATestPath;

mkdir(saveDataPath);
mkdir(savePCAPath);

dlmwrite(strcat(saveDataPath,'/positive_data.txt'),dataMtx);
dlmwrite(strcat(savePCAPath,'/data_coeff.txt'),posData_coeff);

% Adding classification lable
y=zeros(size(dataMtx,1),1);
y(:)=1;dataMtx=horzcat(dataMtx,y);
dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx);

y=zeros(size(posData_coeff,1),1);
y(:)=1;posData_coeff=horzcat(posData_coeff,y);
dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),posData_coeff);

%clear dataMtx;
clear posData_coeff;

%% 2.3 TEST DATA: Fetching Negative data

[dataMtx,totalRecord]=getImgDataAsDataMtx(testNegDataPath,[imgHeight,imgWidth]);
% Finding -ve Data Eigen Coeffient 
negData_coeff= bsxfun(@minus,dataMtx,mu)*coeff;
%% 2.4 TEST DATA: Save on to the file

saveDataPath = saveDataTestPath;
savePCAPath = savePCATestPath;

dlmwrite(strcat(saveDataPath,'/negative_data.txt'),dataMtx);
dlmwrite(strcat(savePCAPath,'/negdata_coeff.txt'),negData_coeff);

% Adding classification lable
y=zeros(size(dataMtx,1),1);
y(:)=-1;dataMtx=horzcat(dataMtx,y);
dlmwrite(strcat(saveDataPath,'/complete_data.txt'),dataMtx,'-append');

y=zeros(size(negData_coeff,1),1);
y(:)=-1;negData_coeff=horzcat(negData_coeff,y);
dlmwrite(strcat(savePCAPath,'/complete_data_coeff.txt'),negData_coeff,'-append');

%clear dataMtx;
clear negData_coeff;
%% 

