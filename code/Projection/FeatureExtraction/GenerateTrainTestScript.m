%% Divide dataset into two parts train and test
%% Init
server=0;
basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/';
testDateInPercent=25;% 25%

%pca
%dir= strcat(basepath,'/_pca_data-Y,Z,Neg','v.10');
%datafileName= 'complete_data_coeff.txt';

% complete data
if server 
    dir= strcat(basepath,'/_data-Y,Z,Neg','v.10');
else
    dir= strcat(basepath,'/_data-Y,Z,Neg','v.10','/set1');
end
    datafileName= 'complete_data.txt';

status= generateTrainTestDataset(dir,datafileName,testDateInPercent);

fprintf('\n** GENERATION OF TRAIN AND TEST COMPLETED **\n');
%%

