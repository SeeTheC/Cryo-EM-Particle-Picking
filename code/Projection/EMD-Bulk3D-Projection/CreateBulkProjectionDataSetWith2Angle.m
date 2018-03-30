%% EMD 3D Projection
% By: Khursheed Ali. (March 2018) 
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
%% Reading Emd virus 
 datasetPath='~/git/Dataset/EM';
 em1003File=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map');
 em1003 = mapReader(em1003File);
 em5693File=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
 em5693 = mapReader(em5693File);
 
 %em2198File=strcat(datasetPath,'/EMD-2198','/map','/EMD-2198.map');
 %em2198 = mapReader(em2198File);
 %em2211File=strcat(datasetPath,'/EMD-2211','/map','/EMD-2211.map');
 %em2211 = mapReader(em2211File);
 
 
 %% Set Particle
 data=em5693;
 dataNum=5693;
 dim=size(data);
 saveParentPath='../SavedFile/';
 %%  Projection
 
 % INIT
 totalAnglesY = linspace2(0, 2*pi, 10);
 totalAnglesZ = linspace2(1, pi, 10);
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
 
 