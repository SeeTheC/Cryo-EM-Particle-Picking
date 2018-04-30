%% EMD 3D Projection
% By: Khursheed Ali. (March 2018) 
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
%% Reading Emd virus 
 datasetPath='~/git/Dataset/EM';
 % ------------------------[Config]------------------------------
 %em5693File=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map'); dataNum=5693;  emFile=em5693File;
 %em1003File=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); dataNum=1003;  emFile=em1003File;
 %em2198File=strcat(datasetPath,'/EMD-2198','/map','/EMD-2198.map'); dataNum=2198;  emFile=em2198File;
 %em2211File=strcat(datasetPath,'/EMD-2211','/map','/EMD-2211.map'); dataNum=2211;  emFile=em2211File;
 %em5689File=strcat(datasetPath,'/EMD-5689','/map','/EMD-5689.map');  dataNum=5689;  emFile=em5689File;
 em5762File=strcat(datasetPath,'/EMD-5762','/map','/EMD-5762.map');  dataNum=5762;  emFile=em5762File;
 
 % --------------------------------------------------------------  

 %% Set Particle
 data=mapReader(emFile);
 dim=size(data);
 saveParentPath='../SavedFile/';
 %%  Projection
 
 % INIT
 totalAnglesY = linspace2(0, 2*pi, 65);
 totalAnglesZ = linspace2(0, pi,  65);
 
 % For Testing
 %totalAnglesY = linspace2(10, 2*pi, 10);
 %totalAnglesZ = linspace2(10, pi,  2);
 
 anglesCountY= numel(totalAnglesY);
 anglesCountZ= numel(totalAnglesZ);
 
 timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
 savepath=strcat(saveParentPath,'Projection_',num2str(dataNum),'_',timestamp); 
 savedImgDir=strcat(savepath,'/img');
 savedRawImgDir=strcat(savepath,'/raw_img');
 
 
 % Creating dir
 mkdir(savepath);
 mkdir(savedImgDir);
 mkdir(savedRawImgDir);
 
 % creating a file
fid = fopen(strcat(savepath,'/0_info.txt'), 'a+');
fprintf(fid, 'img_no \t max_int_value \t angleY \t angleZ \n');

%% Create Projection
angles=totalAnglesY; 
for i=1:anglesCountZ 
     fprintf('Projection: %d /%d\n',i,anglesCountZ);    
     angleZ=totalAnglesZ(i);          
     projection=take3DProjectionWith2Angles(data,angles,angleZ);
     
     % save projection
     for j=1:anglesCountY
        img=projection(:,:,j);
        maxValue=max(img(:));
        imgNum=(i-1)*anglesCountY+j;
        imwrite(img/maxValue,strcat(savedImgDir,'/',num2str(imgNum),'.jpg'));
        % writing to file
        fprintf(fid, '%d \t %f \t %f \t %f\n',imgNum,maxValue,angles(j),angleZ);
        % saveing raw img
        save( strcat(savedRawImgDir,'/',num2str(imgNum),'.mat'),'img');
        
     end
 end
 

fclose(fid);
fprintf('Processing Done\n');
 %%
 
 