%% Partilce Recognitiong using Faster R-CNN: Train
%% Init: Config
clear all;
addpath(genpath('../../MapFileReader/'));
addpath(genpath('../../Classification/DrawBox/'));
addpath(genpath('../../../EM-Micrograph/script'));
fprintf('Initializing..\n');
server=2
if server == 1
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                           
else
     basepath='/media/khursheed/4E20CD3920CD2933/MTP/'; 
end 

%----------------------------[Config:1]--------------------------------------
dataset='_dl-proj-10025v.10_mghw_1000';
%trainedModelpath='8.model_vgg16_full';% used when trainNewModel = false i.e for loading already trained model
trainedModelpath='14.model_vgg16trav3_2';% used when trainNewModel = false i.e for loading already trained model
processMultipleMg=true;
coordMetadataPath=strcat(basepath,'/10025/','run1_shiny_mp007_data_dotstar.txt.star'); 

%--------------------------------------------------------------------------

%% Path Init 2
datasetPath = strcat(basepath,'/',dataset);
savedBasepath=strcat(datasetPath,'/trained_model');
savedModelPath=strcat(savedBasepath,'/',trainedModelpath);
savedResultBP=strcat(savedModelPath,'/Result');
mkdir(savedResultBP);
fprintf('Done.\n');
%% Loading Trained Model
     
fprintf('Loading Pretrained Model..\n');
% Loading Saved Model
modelpath=strcat(savedModelPath,'/','detector.mat');
sobj=load(modelpath);
trainedModel=sobj.detector; 
fprintf('Completed..\n');
    
%% Single Micrograph

if(processMultipleMg)
    %  Loading Micrograph
    fprintf('Testing on image..\n')
    % Base: /10025/data/14sep05c_averaged_196/
    %mgName='14sep05c_00024sq_00003hl_00002es_c.mrc';
    %mgName='14sep05c_c_00004gr_00032sq_00015hl_00004es_c'
    % Test Micrograph
    mgName='14sep05c_c_00006gr_00030sq_00005hl_00003es_c';
    
    %mgFile=strcat(basepath,'/10025/data/14sep05c_averaged_196/',mgName,'.mrc');
    mgFile=strcat(datasetPath,'/Test_Micrograph/',mgName,'.mrc');
    [micrograph,~,~,~,~]=ReadMRC(mgFile);
    % Predict on collage
    fprintf('Predicting on Single Micrograph...\n');
    downsample=4;

    config.trainedModel=trainedModel;
    config.micrograph=micrograph;    
    config.minScoreProbability=0.4;
    config.visualDownsample=12;
    % downsample
    config.downsample=downsample;
    %config.downsampleList=[4,3,3.5,2.5,2];
    config.downsampleList=[4];
    
    %Filter
    config.applyWienerFiter=true; 
    % True and Predicted mapping
    config.nnThreshold=216/2;
    %Segment Mircograph
    config.segmentAndPredict=true; % Divide Mg into smaller micrograph and then process
    config.segmentMaxHW=1000;
    config.segmentStride=500;
    config.segmentSupressionDiameter=216; % size of particle

    % Mark center
    config.markCenterOnImg=true;
    config.coordMetadataPath=coordMetadataPath;
    config.mgName=mgName;
    
    % Faster-RCNN
    config.minInputLayerSize=225;
    
    % Save
    % Create Save Directory
    savedMgResult=strcat(savedResultBP,'/',mgName);mkdir(savedMgResult);
    config.save=savedMgResult;
    
    [accuracy,correctlyPredCount,...
     trueCount,mapping,...
     transError,resultTable,predLocFilter,...
     predImg,predTrueImg]=predictOnFullMicrograph(config);
    fprintf('Done.');
    figure, imshow(predTrueImg),impixelinfo;
end
%% Multiple Micrograph
if(processMultipleMg)
    fprintf('Processing Multiple Micrograph...\n');
    mgPath=strcat(datasetPath,'/Test_Micrograph');
    % Reading Files Name
    filename=getDirFilesName(mgPath);
    noOfMg=numel(filename);
    fprintf('** Number of Micrograph to process:%d\n',noOfMg);
    % Process each Micrograph
    allTransError=[];
    table=cell2table(cell(0,12));
    table.Properties.VariableNames = {'name','trueCount' 'totalPredLoc' 'correctlyPredCount' 'extraPred','minTranslationError','maxTranslationError','avgTranslationError','medianTransLationError','accuracy','precision','prediction_time'};    
    for i=1:noOfMg
        mgDir=filename{i};
        temp=strsplit(mgDir,'.mrc');
        mgName=temp{1};
        % Load Micrograph
        mgFile=strcat(mgPath,'/',mgName,'.mrc');
        [micrograph,~,~,~,~]=ReadMRC(mgFile);
        % Create Save Directory
        savedMgResult=strcat(savedResultBP,'/',mgName);
        mkdir(savedMgResult);
        % ----------[ Config: Start ]-------------------- 
        downsample=12;
        config.trainedModel=trainedModel;
        config.micrograph=micrograph;
        config.minScoreProbability=0.0;
        config.visualDownsample=12;
       % downsample
        %config.downsample=downsample;
        config.downsampleList=[4,3,2];
    
        %Filter
        config.applyWienerFiter=true; 

        %Segment Mircograph
        config.segmentAndPredict=true; % Divide Mg into smaller micrograph and then process
        config.segmentMaxHW=1000;
        config.segmentStride=500;
        config.segmentSupressionDiameter=216; % size of particle
        
        % True and Predicted mapping
        config.nnThreshold=216/2;
        
        % Mark center
        config.markCenterOnImg=true;
        config.coordMetadataPath=coordMetadataPath;
        config.mgName=mgName;
        
        % Faster-RCNN
        config.minInputLayerSize=225;
    
    
        % Save
        config.save=savedMgResult;
        % ----------[ Config: End ]--------------------
    
        % Process
        fprintf('** Processing Mg(%d): %s\n',i,mgName);
        fprintf('\n------------------------------------------------------------\n');
        pause(2);
        [accuracy,correctlyPredCount,trueCount,mapping,transError,resultTable]=predictOnFullMicrograph(config);    
        table=[table;table2cell(resultTable)];
        allTransError=[allTransError;transError];
        fprintf('\n=============================================================\n');        
    end
     % Saving Result
    saveCumulativeResult=strcat(savedResultBP,'/_result');
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
    
    % Histogram
    bEdge=[0:3:(216+2)/2];
    xticks(bEdge);
    histogram(allTransError,bEdge);
    xticks(bEdge);
    xlabel('Translation Error');
    ylabel('Frequency Count');
    tstr=sprintf('\\fontsize{14}{\\color{magenta}Translation Error Histogram (Particles:%d) }',numel(allTransError));
    title(tstr);
    saveas(gcf,strcat(saveCumulativeResult,'/','Translation_Error_Histogram.png'));
    fprintf('**Completed Processing Multiple Micrograph.\n');
    
    fprintf('Completed.');
end

