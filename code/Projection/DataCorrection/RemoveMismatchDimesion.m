% Synchonize the raw and img data consistent
% Usually it uses for removing the outlier in case of  -neg images
%% Init
server=1
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

% ---------------------[Config]-----------------------------
basepath=strcat(basepath,'/_data-proj-5689v.10','/train');
correctDim=[278,278];
%---------------------------------------------------------------
imgPath=strcat(basepath,'/img');
rawPath=strcat(basepath,'/raw_img');
%% Syn Datset
  imgFiles = getDirFilesName(imgPath);
  noOfImgFiles=size(imgFiles,2);
  %%
  for i=1:noOfImgFiles
     fname=imgFiles{i};
     img=imread(strcat(imgPath,'/',fname));
     dim=size(img);
     splitResult=strsplit(fname,'.');
     imgNum=splitResult{1}; 
     if dim(1)~= correctDim(1) && dim(2)~= correctDim(2)
        fprintf('File %s has INCORRECT dim as %dx%d\n',fname,dim(1),dim(2)); 
        rfile= strcat(rawPath,'/',imgNum,'.mat');
        ifile= strcat(imgPath,'/',imgNum,'.jpg');        
        if exist(rfile, 'file')==2
            delete(rfile);
        else
            fprintf('\nERROR: FILE %s id NOT PRESENT',rfile);
        end
        if exist(ifile, 'file')==2
            delete(ifile);
        else
            fprintf('\nERROR: FILE %s id NOT PRESENT',yfile);
        end

     end    
  end
