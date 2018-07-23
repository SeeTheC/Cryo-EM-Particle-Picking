%% INIT
clear all;
addpath(genpath('../../DataCorrection'));
multipleMg=true;
if(multipleMg)
    fprintf('** Processing Multiple Micrograph\n');
else
    fprintf('Processing Single Micrograph\n');
end
config=struct;
config.server=2;
config.imgdim=[216,216];
config.modelType=ModelType.CompactSVM;
config.isThreaded=false;
config.gpu=true;

config.collageDir='collage';   
config.dataset='_data-proj-10025v.10';

%% Single Micrograph

if(~multipleMg)
    config.scale=[4,8,12];
    config.collageNum='14sep05c_c_00007gr_00021sq_00017hl_00002es_c';        
    %config.model='/model_1-2-4-8_18000';
    config.model='/model_4-8-12_18000';
    config.savepathPrefix='postfix_tr_18000';
    config.maxCollageSize=[];    
    config.minProbabiltyScore=0.6;

    status=mainScaleModelOnCollage(config);
    fprintf('**Completed with status:%s\n',status);

end
%% Multiple Files
if(multipleMg)
    if config.server==1
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
    elseif config.server==2
        basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset';                              
    else
        basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
     end
    basepath=strcat(basepath,'/',config.dataset);                       
    testPath=strcat(basepath,'/test');
    testCollagePath= strcat(testPath,'/',config.collageDir,'/Test_Micrograph/');     

    % Reading Files Name
    filename=getDirFilesName(testCollagePath);
    noOfMg=numel(filename);
    fprintf('** Number of Micrograph to process:%d\n',noOfMg);
    % Process each Micrograph

    config.scale=[4,8,12];
    config.model='/model_4-8-12_18000';
    config.savepathPrefix='postfix_tr_18000';    
    config.maxCollageSize=[];    
    config.minProbabiltyScore=0.6;
    
    for i=1:noOfMg
        mgName=filename{i};
        temp=strsplit(mgName,'.');
        mgName=temp{1};
        config.collageNum=mgName;        
        fprintf('** Processing Mg(%d): %s\n',i,mgName);
        fprintf('\n------------------------------------------------------------\n');
        pause(5);
        status=mainScaleModelOnCollage(config);
        fprintf('\n=============================================================\n');

    end
    fprintf('**Completed Processing Multiple Micrograph.\n');

end






%%









