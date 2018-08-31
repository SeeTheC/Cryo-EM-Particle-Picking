function [accuracy,correctlyPredCount,trueCount,mapping,transError,resultTable] = getMgAccuracy(config)
    %% Init
    basepath=config.basepath;    
    basepath=strcat(basepath,'/',config.dataset); 
    
    collageDir=config.collageDir;   
    modelType=config.modelType;   
    model=config.model;            
    probThershold=config.probThershold;
    
    cellH=config.cellDim(1)/config.downscale; cellW=config.cellDim(2)/config.downscale;
    
    supressBoxSize=config.supressBoxSize./config.downscale;    
    collageNum=config.collageNum; 
    coordMetadataPath=strcat(basepath,'/',config.coordMetadataPath);    
    
    % setting modeltype
    mt='';
    if modelType==ModelType.CompactSVM   
        mt='svm-linear-40TC'; 
    elseif modelType==ModelType.RandomForest
        mt='ramdomForest-50trees-40TC'; %-40TC
    elseif modelType==ModelType.DecisionTree
        mt='decisionTree';
    end

    % save location
    %trainPath=strcat(basepath,'/train','/',collageDir);
    testPath=strcat(basepath,'/test','/',collageDir);
    testCollageRawPath= strcat(testPath,'/processed_img/',mt);
    testCollageRawPath= strcat(testCollageRawPath,'/',config.mgDir);
    testCollageRawPath=strcat(testCollageRawPath,'/',model,'/model-',num2str(config.scaleModel));
    
    %loading score collage
    name=strcat(testCollageRawPath,'/',collageNum,'.mat');
    struct=load(name);
    scoreCollage=struct.outImg;
    [H,W]=size(scoreCollage);

    fprintf('Init Done.\n');
    %% Finding location using maxmial suppression
    %probThershold=0.4;
    boxSize=[cellH,cellW];
    [cX,cY]=findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,8000);    
    totalPredLoc=size(cX,1);
    fprintf('noOfPredictedLoc:%d .Done...\n',totalPredLoc); 
  %% Scaling
    H=H*config.downscale;W=W*config.downscale;
    cX=cX*config.downscale;
    cY=cY*config.downscale;
    predictedLoc=[cX,cY];
    %% Fetching TRUE cordinates
    [trueKnownCoord,keyword]=getRelionCoordinate(config.coordMetadataSearchStr,coordMetadataPath);
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
    %%  Finding Result    
    fid = fopen(strcat(testCollageRawPath,'/result.txt'), 'w+');    
    accuracy=correctlyPredCount/trueCount;
    extraPred=totalPredLoc-correctlyPredCount;
    precision=correctlyPredCount/totalPredLoc;
    mapping=result;
    distList=mapping(mapping(:,5)<Inf,5);
    transError=distList;
    avgTranslationError=ceil(sum(distList)/correctlyPredCount);  
    minTranslationError=round(min(distList));
    maxTranslationError=round(max(distList));
    medianTransLationError=median(int16(round(distList)));
    resultCell={config.collageNum,trueCount,totalPredLoc,correctlyPredCount,extraPred,minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError,accuracy,precision};
    fprintf('----------------------------------------------------------------\n');
    fprintf('****Result:\nTrue Loc Count:\t%d \nTotal Pred. Count:\t%d \nCorrectly Pred. Count:\t%d \nExtra Predicted Count:\t%d \n',trueCount,totalPredLoc,correctlyPredCount,extraPred);   
    fprintf('Min Translation Error:\t%d pixel\nMax Translation Error:\t%d pixel\nAvg Translation Error:\t%d pixel\nMed Translation Error:\t%d pixel\n',minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError);         
    fprintf('\nAccuracy:\t%f\nPrecision:\t%f\n',accuracy,precision);     
    fprintf(fid,'****Result:\nTrue Loc Count:\t%d \nTotal Pred. Count:\t%d \nCorrectly Pred. Count:\t%d \nExtra Predicted Count:\t%d \n',trueCount,totalPredLoc,correctlyPredCount,extraPred);   
    fprintf(fid,'Min Translation Error:\t%d pixel\nMax Translation Error:\t%d pixel\nAvg Translation Error:\t%d pixel\nMed Translation Error:\t%d pixel\n',minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError);         
    fprintf(fid,'\nAccuracy:\t%f\nPrecision:\t%f\n',accuracy,precision);     
    fclose(fid);
    resultTable=cell2table(resultCell);
    resultTable.Properties.VariableNames = {'name','trueCount' 'totalPredLoc' 'correctlyPredCount' 'extraPred','minTranslationError','maxTranslationError','avgTranslationError','medianTransLationError','accuracy','precision'};
    fprintf('----------------------------------------------------------------\n');   
    %return 
    %% Marking Center Config
    maxCollageSize=config.maxCollageSize;
    if config.server==2
        originalCollageName= strcat(testPath,'/',config.collageSubDir,'/',collageNum,'.mrc');  
        [collage,~,~,~,~]=ReadMRC(originalCollageName);
        if(size(maxCollageSize,1)==0)
            maxCollageSize=size(collage);
        end
        collage=collage(1:maxCollageSize(1),1:maxCollageSize(2));    
    else
        originalCollageName=strcat(testPath,'/',config.collageSubDir,'/',collageNum,'.mat');
        struct=load(originalCollageName);
        collage=struct.img;
        if(size(maxCollageSize,1)==0)
            maxCollageSize=size(collage);
        end
        collage=collage(1:maxCollageSize(1),1:maxCollageSize(2));    
        
    end
    %if(config.downscale~=1)
    %    collage=imresize(collage,1/config.downscale);        
    %end
    drawingConfig.originalMg=collage;
    %drawingConfig.visualDownsample=config.downscale;  
    drawingConfig.visualDownsample=config.visualDownsample;
    %drawingConfig.downscaleModel=config.downscale;
    drawingConfig.predictedLoc=predictedLoc;
    drawingConfig.trueKnownLoc=trueKnownCoord;
    drawingConfig.savepath=testCollageRawPath;    
    % MarkCenter
    [predImg,predTrueImg] = markCenterParticle(drawingConfig);
end

