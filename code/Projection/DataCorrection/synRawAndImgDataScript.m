% Synchonize the raw and img data consistent
% Usually it uses for removing the outlier in case of  -neg images
%% Init

basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/_data-Y,Zv.10/';
%basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/_data-proj-2211v.10';

basepath=strcat(basepath,'/Noisy_downscale2');
basepath=strcat(basepath,'/test/NegImg');

imgPath=strcat(basepath,'/img');
rawPath=strcat(basepath,'/raw_img');

%% Syn Datset
  imgFiles = getDirFilesName(imgPath);
  rawFiles = getDirFilesName(rawPath);
  %%  
  noOfRawFiles=size(rawFiles,2);
  noOfImgFiles=size(imgFiles,2);
  for i=1:noOfRawFiles
     rfn=rawFiles(i);
     rfn=rfn{1};
     splitResult=strsplit(rfn,'.');
     imgNum=splitResult{1};    
     present=any(strcmp(imgFiles, strcat(imgNum,'.jpg') ));
     if present==0
        fprintf('File %s.jpg is not Present. So Deleting %s.mat file\n',imgNum,imgNum); 
        file= strcat(rawPath,'/',imgNum,'.mat');
        if exist(file, 'file')==2
            delete(file);
        else
            fprintf('\nERROR: FILE %s id NOT PRESENT',file);
        end
     end    
  end
