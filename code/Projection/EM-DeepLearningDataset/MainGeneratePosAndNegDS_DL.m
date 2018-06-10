%% INIT
clear all;
addpath('../DataCorrection/');
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
addpath(genpath('../EM-Micrograph/script'));

server=2;

if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end  

%----------------------------[Config]-------------------------------
sample='10025';
micrographDir='14sep05c_averaged_196';
coordinateMetadata='run1_shiny_mp007_data_dotstar.txt.csv';
patchSize=([18,18]).*12;
testPercent=20; % in percentage
%-------------------------------------------------------------------
basepath=strcat(basepath,'/',sample);
mgPath=strcat(basepath,'/data/',micrographDir);
coordMetadataPath=strcat(basepath,'/',coordinateMetadata);
fprintf('Init Done\n');
%% Process
[status] = generatePosAndNegDS_DL(mgPath,patchSize,coordMetadataPath,testPercent,basepath);
fprintf("%s\n",status);
