function [accuracy,correctlyPredCount,trueCount,mapping] = getMgAccuracy(config)
    %% Init
    basepath=config.basepath;    
    basepath=strcat(basepath,'/',config.dataset); 
    
    collageDir=config.collageDir;   
    modelType=config.modelType;   
    model=config.model;            
    probThershold=config.probThershold;
    
    cellH=config.cellDim(1); cellW=config.cellDim(2);
    supressBoxSize=config.supressBoxSize;    
    collageNum=config.collageNum; 
    coordMetadataPath=strcat(basepath,'/',config.coordMetadataPath);    
    
    % setting modeltype
    mt='';
    if modelType==ModelType.CompactSVM   
        mt='svm'; 
    elseif modelType==ModelType.RandomForest
        mt='ramdomForest';
    elseif modelType==ModelType.DecisionTree
        mt='decisionTree';
    end

    % save location
    %trainPath=strcat(basepath,'/train','/',collageDir);
    testPath=strcat(basepath,'/test','/',collageDir);
    testCollageRawPath= strcat(testPath,'/processed_img/',mt);
    testCollageRawPath= strcat(testCollageRawPath,'/',config.mgDir);
    testCollageRawPath=strcat(testCollageRawPath,'/',model,'/model-1');
    
    %loading score collage
    name=strcat(testCollageRawPath,'/',collageNum,'.mat');
    struct=load(name);
    scoreCollage=struct.outImg;
    [H,W]=size(scoreCollage);

    fprintf('Init Done.\n');
    %% Finding location using maxmial suppression
    %probThershold=0.4;
    boxSize=[cellH,cellW];
    [cX,cY]=findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,1000);
    totalPredLoc=size(cX,1);
    fprintf('noOfPredictedLoc:%d .Done...\n',totalPredLoc); 
    
    %% Fetching TRUE cordinates
    [trueKnownCoord,keyword]=getRelionCoordinate(collageNum,coordMetadataPath);
    noOfTrueLoc=size(trueKnownCoord,1);
    %% Finding NEAREST NEIGBOUR MAPPING OF PREDICTED AND TRUE COORDINATE
    result=[];
    correctlyPredCount=0;
    trueCount=0;
    for i=1:noOfTrueLoc        
        row=trueKnownCoord(i,:);
        tx=row.x;ty=row.y;
        if(tx>H || ty>W)
            continue;
        end
        trueCount=trueCount+1;
        minDist=Inf;
        minIdx=0;     
        noOfPredLoc=size(cX,1);
        if isempty(cX)
            continue;
        end
        %fprintf('noOfPredLoc:%d\n',noOfPredLoc);        
        for pIdx=1:noOfPredLoc
            px=cX(pIdx);py=cY(pIdx);
            if(px<1 || py <1)
                continue;
            end
            dist=norm([px-tx,py-ty]);
            if dist<minDist && dist<config.nnThreshold
                minIdx=pIdx;
                minDist=dist;
            end
        end
        if(minIdx ~=0)
            px=cX(minIdx);py=cY(minIdx);
            correctlyPredCount=correctlyPredCount+1;
            result=[result;tx,ty,px,py,minDist];
            cX(minIdx)=[];cY(minIdx)=[];
        else
            result=[result;tx,ty,-1,-1,Inf];                       
        end
    end
    %%    
    accuracy=correctlyPredCount/trueCount;
    extraPred=totalPredLoc-correctlyPredCount;
    mapping=result;
    avgTranslationError=ceil(sum(mapping(mapping(:,5)<Inf,5))/correctlyPredCount);
    fprintf('----------------------------------------------------------------\n');
    fprintf('****Result:\nnoOfTrueLoc:%d \ntotalPredLoc:%d \ncorrectlyPredCount:%d \nextraPred:%d \navgTranslationError:%d pixel\naccuracy:%f\n',trueCount,totalPredLoc,correctlyPredCount,extraPred,avgTranslationError,accuracy);   
    fprintf('----------------------------------------------------------------\n');
    
    
end

