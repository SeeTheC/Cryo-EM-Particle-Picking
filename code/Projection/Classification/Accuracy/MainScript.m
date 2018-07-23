%% MAIN SCRIPT: ACCURACY CALCULATION

%% Init
    clear all;
    addpath(genpath('../'));
    addpath(genpath('../../MapFileReader/'));
    addpath(genpath('../../DataCorrection/'));
    addpath(genpath('../../EM-Micrograph/script'));
    server = 2;
    if server==1
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    elseif server==2
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                              
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
    end    

    config=struct;
    config.server=server;
    config.collageDir='collage';   
    config.dataset='_data-proj-10025v.10'; % img dimension: [216,216]     
    config.cellDim=[216,216];
    config.supressBoxSize=[216,216];        
    config.basepath=basepath;
    config.nnThreshold=max(config.cellDim(:))/2;
    
%%  Single Config
    
    %----------------------------------------------------------------------
    %{  
    % Mg Setting: 1
    config.probThershold=0.70;  
    config.maxCollageSize=[5000,5000];
    config.modelType=ModelType.RandomForest;      
    config.mgDir='14sep05c_00024sq_00003hl_00002es_c_tr_18000';     
    config.model='model_1-2-4-8_18000';          
    config.scaleModel=1;
    config.scale=1;
    config.collageNum='14sep05c_00024sq_00003hl_00002es_c';         
    config.coordMetadataPath='10025/run1_shiny_mp007_data_dotstar.txt.csv';    
    %}
    
    %%{  
    % Mg Setting: 2 T20 Prototsome
    
    config.probThershold=0.97;   
    %config.maxCollageSize=[5000,5000];
    config.maxCollageSize=[];    
    config.modelType=ModelType.CompactSVM;      
    %config.mgDir='14sep05c_c_00007gr_00021sq_00016hl_00003es_c_tr_18000_maxHW5000x5000';     
    config.mgDir='14sep05c_c_00007gr_00021sq_00017hl_00002es_c_postfix_tr_18000';             
    %config.mgDir='14sep05c_c_00006gr_00030sq_00008hl_00002es_c_postfix_tr_18000';
    config.model='model_4-8-12_18000';          
    %config.model='model_1-2-4-8_18000';      
    config.scaleModel=3;% which scale model to test
    config.downscale=12; % what is the downscale value fo micrograph;
    config.collageNum='14sep05c_c_00007gr_00021sq_00017hl_00002es_c';        
    config.coordMetadataPath='10025/run1_shiny_mp007_data_dotstar.txt.csv';    
    %}
    %----------------------------------------------------------------------
    

% Call
 [accuracy,correctlyPredCount,trueCount,mapping,transError,resultTable]=getMgAccuracy(config);
 
%% Multiple Micrograph

config.probThershold=0.95;   
config.maxCollageSize=[];    
config.modelType=ModelType.CompactSVM;      
config.model='model_4-8-12_18000';          
config.scaleModel=3;% which scale model to test
config.downscale=12; % what is the downscale value fo micrograph;
config.coordMetadataPath='10025/run1_shiny_mp007_data_dotstar.txt.csv';    

mt='';
if config.modelType==ModelType.CompactSVM   
    mt='svm-linear-40TC'; 
elseif config.modelType==ModelType.RandomForest
    mt='ramdomForest-50trees-40TC'; %-40TC
elseif config.modelType==ModelType.DecisionTree
    mt='decisionTree';
end

testPath=strcat(basepath,'/',config.dataset);                       
testPath=strcat(testPath,'/test','/',config.collageDir);
testCollageRawPath= strcat(testPath,'/processed_img/',mt);
%testCollageRawPath= strcat(testCollageRawPath,'/',config.mgDir);
    
% Reading Files Name
filename=getDirFilesName(testCollageRawPath);
noOfMg=numel(filename);
fprintf('** Number of Micrograph to process:%d\n',noOfMg);
% Process each Micrograph
allTransError=[];
table=cell2table(cell(0,11));
table.Properties.VariableNames = {'name','trueCount' 'totalPredLoc' 'correctlyPredCount' 'extraPred','minTranslationError','maxTranslationError','avgTranslationError','medianTransLationError','accuracy','precision'};    
for i=1:noOfMg
    mgDir=filename{i};
    temp=strsplit(mgDir,'_postfix_');
    mgName=temp{1};
    config.collageNum=mgName;
    config.mgDir=mgDir;
    
    fprintf('** Processing Mg(%d): %s\n',i,mgName);
    fprintf('\n------------------------------------------------------------\n');
    pause(2);
    [accuracy,correctlyPredCount,trueCount,mapping,transError,resultTable]=getMgAccuracy(config);    
    table=[table;table2cell(resultTable)];
    allTransError=[allTransError;transError];
    fprintf('\n=============================================================\n');

end
% Saving Result
saveCumulativeResult=strcat(testCollageRawPath,'/_result');
mkdir(saveCumulativeResult);

tempTable=table;
tempTable.accuracy=tempTable.accuracy*100;
tempTable.precision=tempTable.precision*100;
writetable(tempTable,strcat(saveCumulativeResult,'/','all_readings.csv'));

% saveing result to file
fid=fopen(strcat(saveCumulativeResult,'/','avg_result.txt'),'w+');
fprintf(fid,'** Result  \n');
fprintf(fid,'Total Micrgraph: %d\n',noOfMg);
fprintf(fid,'Each Micrograph size: 7420x7676 \n');
fprintf(fid,'Total Predicted Particles: %d\n',numel(allTransError));
fprintf(fid,'\nAccuracy/Recall: %f\n',mean(tempTable.accuracy));
fprintf(fid,'Precision: %f\n',mean(tempTable.precision));
fprintf(fid,'\nAvg Translation Error: %d pixel\n',round(mean(allTransError)));
fprintf(fid,'Med Translation Error: %d pixel\n',round(median(allTransError)));
fprintf(fid,'Min Translation Error: %d pixel\n',round(min(allTransError)));
fprintf(fid,'Max Translation Error: %d pixel\n',round(max(allTransError)));
fclose(fid);
%% Histogram
bEdge=[0:3:(216+2)/2];
xticks(bEdge);
histogram(allTransError,bEdge);
xticks(bEdge);
xlabel('Translation Error');
ylabel('Frequency Count');
tstr=sprintf('\\fontsize{14}{\\color{magenta}T20 Proteasome:Translation Error Histogram (Particles:%d) }',numel(allTransError));
title(tstr);
saveas(gcf,strcat(saveCumulativeResult,'/','Translation_Error_Histogram.png'));
fprintf('**Completed Processing Multiple Micrograph.\n');

%%

%%







