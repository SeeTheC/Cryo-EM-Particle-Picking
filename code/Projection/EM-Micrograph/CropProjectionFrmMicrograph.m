%%
addpath('../DataCorrection/');
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
%% Init
clear all;
server=0;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/RealDataset';  
end
basepath=strcat(basepath,'/Micrograph');
%----------------------------[Config]-------------------------------
sample='EM-10025';
micrographDir='14sep05c_averaged_196';
coordinateMetadata='run1_shiny_mp007_data_dotstar.txt.csv';
patchSize=([18,18]).*12;
%-------------------------------------------------------------------
basepath=strcat(basepath,'/',sample);
mgPath=strcat(basepath,'/data/',micrographDir);
coordMetadataPath=strcat(basepath,'/',coordinateMetadata);

%% Process
[status] = cropPosAndNegProjection(mgPath,patchSize,coordMetadataPath,basepath);
fprintf("%s\n",status);
%%


























