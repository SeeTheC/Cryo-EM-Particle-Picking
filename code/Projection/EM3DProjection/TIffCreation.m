addpath('../DataCorrection/');
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));

server=2;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server==1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/mtp-data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP'; 
    basepath=strcat(basepath,'/Micrograph');
end
%------------[CONFIG]----------------------
dataset='Projection_5689_Y/img';

%------------------------------------------
datasetPath=strcat(basepath,'/',dataset);

%%
 fileList=getDirFilesName(datasetPath,'jpg');    
 noOfImg=size(fileList,2);
 fprintf(' No of Projection:%d\n',noOfImg);
 for i=1:noOfImg
     filename=fileList{i}
     img=imread(strcat(datasetPath,'/',filename));
     if(i==1)
        imwrite(img,'multipleProjection1.tif');
     else
        imwrite(img,'multipleProjection1.tif','WriteMode','append')
     end
 end
    
%% Example
im1 = rand(50,40,3);
im2 = rand(50,50,3);
imwrite(im1,'myMultipageFile.tif')
imwrite(im2,'myMultipageFile.tif','WriteMode','append')







