%% Init
clear all;

addpath('../DataCorrection/');
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));

server=1;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset/T20_Proteasome/ftp.ebi.ac.uk/pub/databases/empiar/archive';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/RealDataset'; 
    basepath=strcat(basepath,'/Micrograph');
end
%----------------------------[Config]-------------------------------
sample='10025';
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


























