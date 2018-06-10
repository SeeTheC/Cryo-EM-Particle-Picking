%% MAIN SCRIPT: ACCURACY CALCULATION

%% Init
    clear all;
    addpath(genpath('../'));
    addpath(genpath('../../MapFileReader/'));
    addpath(genpath('../../EM-Micrograph/script'));
    server = 2;
    if server==1
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    elseif server==2
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                              
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
    end    

%% Config
    config=struct;
    config.server=server;
    config.collageDir='collage';   
    config.maxCollageSize=[5000,5000];    
    config.probThershold=0.1;
    
    %collage info
    config.cellDim=[216,216];
    config.nnThreshold=max(config.cellDim(:))/2;
    config.supressBoxSize=[216,216];    
    
    config.basepath=basepath;
    config.dataset='/_data-proj-10025v.10'; % img dimension: [216,216]     
    
    config.modelType=ModelType.RandomForest;       
    config.mgDir='14sep05c_00024sq_00003hl_00002es_c_tr_18000';     
    config.model='model_1-2-4-8_18000';                
    config.collageNum='14sep05c_00024sq_00003hl_00002es_c';     
    config.coordMetadataPath='10025/run1_shiny_mp007_data_dotstar.txt.csv';    


% Call
 [accuracy,correctlyPredCount,trueCount,mapping]=getMgAccuracy(config);
