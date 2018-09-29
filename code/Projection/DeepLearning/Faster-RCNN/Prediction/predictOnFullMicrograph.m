function [accuracy,correctlyPredCount,trueCount,mapping,transError,resultTable,predImg,predTrueImg] = predictOnFullMicrograph(config)
    %% Init
    trainedModel=config.trainedModel;
    micrograph=config.micrograph;
    
    fprintf('Init Done.\n');
    %% Processing Large micrograph by dividing it into smaller one.    
    micrograph=micrograph-min(micrograph(:));
    micrograph=micrograph/max(micrograph(:));    
    imwrite(micrograph,strcat('temp.jpg'));
    micrograph = imread('temp.jpg');   
    
    if(config.segmentAndPredict)
       tic
       finalPredLoc=[];
       for i=1:numel(config.downsampleList)
            config.downsample=config.downsampleList(i);
            predLoc=predictOnSegmentedMicrograph(trainedModel,micrograph,config);
            fprintf('Particle found with downsample:%d are %d',size(predLoc,1));
            finalPredLoc=[finalPredLoc;predLoc];
       end
       predTime=toc;      
       % Removing Duplicates using NMS
       [predLocNMS] = nms(finalPredLoc,config.segmentSupressionDiameter);
       predLoc=predLocNMS;
       predLoc=finalPredLoc;
    else 
       tic
       [predLoc] = predictCompleteMicrograph(trainedModel,micrograph,config);
       predTime=round(toc);     
    end

    fprintf('Prediction Time: %d sec',predTime);
   %% Filter Thershold Probabilty
   
   predLocFilter=predLoc(predLoc(:,3)>config.minScoreProbability,:);
   
   %% Fetching TRUE cordinates
   
   [trueKnownCoord,keyword]=getRelionCoordinate(config.mgName,config.coordMetadataPath);
   
   %% Finding NEAREST NEIGBOUR MAPPING OF PREDICTED AND TRUE COORDINATE
   
   [result,correctlyPredCount,trueCount,totalPredLoc] = nearestNeighbourMapping(trueKnownCoord,predLocFilter,config.nnThreshold,size(micrograph));
      
    %% Finding Accuracy and Precision
   
    fid = fopen(strcat(config.save,'/result.txt'), 'w+');    
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
    resultCell={config.mgName,trueCount,totalPredLoc,correctlyPredCount,extraPred,minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError,accuracy,precision,predTime};
    fprintf('----------------------------------------------------------------\n');
    fprintf('****Result:\nTrue Loc Count:\t%d \nTotal Pred. Count:\t%d \nCorrectly Pred. Count:\t%d \nExtra Predicted Count:\t%d \n',trueCount,totalPredLoc,correctlyPredCount,extraPred);   
    fprintf('Min Translation Error:\t%d pixel\nMax Translation Error:\t%d pixel\nAvg Translation Error:\t%d pixel\nMed Translation Error:\t%d pixel\n',minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError);         
    fprintf('\nAccuracy:\t%f\nPrecision:\t%f\n',accuracy,precision);     
    fprintf(fid,'****Result:\nTrue Loc Count:\t%d \nTotal Pred. Count:\t%d \nCorrectly Pred. Count:\t%d \nExtra Predicted Count:\t%d \n',trueCount,totalPredLoc,correctlyPredCount,extraPred);   
    fprintf(fid,'Min Translation Error:\t%d pixel\nMax Translation Error:\t%d pixel\nAvg Translation Error:\t%d pixel\nMed Translation Error:\t%d pixel\n',minTranslationError,maxTranslationError,avgTranslationError,medianTransLationError);         
    fprintf(fid,'\nAccuracy:\t%f\nPrecision:\t%f\n',accuracy,precision); 
    fprintf(fid,'\nPrediction Time: %d sec\n',predTime);    
    fclose(fid);
    resultTable=cell2table(resultCell);
    resultTable.Properties.VariableNames = {'name','trueCount' 'totalPredLoc' 'correctlyPredCount' 'extraPred','minTranslationError','maxTranslationError','avgTranslationError','medianTransLationError','accuracy','precision','prediction_time'};
    fprintf('----------------------------------------------------------------\n');   
    %% Mark Center On Image
    predImg=[];
    predTrueImg=[];
    if(config.markCenterOnImg)
        drawingConfig.originalMg=double(micrograph);        
        drawingConfig.predictedLoc=[round(predLocFilter(:,1)),round(predLocFilter(:,2))];
        drawingConfig.trueKnownLoc=trueKnownCoord;
        drawingConfig.savepath=config.save;
        drawingConfig.visualDownsample=config.visualDownsample;
        % MarkCenter
        [predImg,predTrueImg] = markCenterParticle(drawingConfig);   
   end
end
% Divide micrograph into smaller micrograph and then find the value
function [predLoc] = predictOnSegmentedMicrograph(trainedModel,micrograph,config)
    %% INIT
    downsample=config.downsample;
    mgMaxHW=config.segmentMaxHW;
    stride=config.segmentStride;
    %% Process
    [mgH,mgW]=size(micrograph);
    mgIdx=1;
    nH=floor(mgH/stride);
    nW=floor(mgW/stride);
    result=[];
    for i=1:nH
        offsetX=(i-1)*stride;
        x1=offsetX+1;x2=x1+mgMaxHW-1;
        if i==nH
            x2=mgH;
        end
        for j=1:nW
            offsetY=(j-1)*stride;
            y1=offsetY+1;y2=y1+mgMaxHW-1;
            if j==nW
                y2=mgW;
            end
            patch=micrograph(x1:x2,y1:y2);   
            % Filter
            if(config.applyWienerFiter)
                patch = wiener2(histeq(imcomplement(patch)),[5 5]); 
            end
            tmpDownsample=downsample;
            [ph,pw]=size(patch);
            if(ph/config.minInputLayerSize < downsample || pw/config.minInputLayerSize < downsample)                
                tmpDownsample=min(floor(ph/config.minInputLayerSize),floor(pw/config.minInputLayerSize));
            end
            % Downsample            
            patch=imresize(patch,1/tmpDownsample);            
            % Predict location
            fprintf('Predicting of partical micrograph (%d/%d,%d/%d) downsampe:%d...\n',i,nH,j,nW,tmpDownsample);           
            [bboxes,scores] = detect(trainedModel,patch);            
            if size(bboxes,1)>0
                for k=1:size(bboxes,1)
                    cx=round(bboxes(k,2)+bboxes(k,4)/2)*tmpDownsample;
                    cy=round(bboxes(k,1)+bboxes(k,3)/2)*tmpDownsample;
                    result=[result; round(x1+cx),round(y1+cy),scores(k)];
                end
            else
                fprintf('**NO Particle FOUND for x1:%d y1:%d x2:%d y2:%d\n',x1,y1,x2,y2);
            end
            mgIdx=mgIdx+1;
        end
    end  
    predLoc=result;
end


function [predLoc] = predictCompleteMicrograph(trainedModel,micrograph,config)
    %% INIT
    downsample=config.downsample;
    %% Process
    pmg=micrograph;
    % Filter    
    if(config.applyWienerFiter)
        pmg = wiener2(histeq(imcomplement(pmg)),[5 5]); 
    end
    pmg=imresize(pmg,1/downsample);  
    % Predict location
    fprintf('Predicting of full micrograph....\n');    
    [bboxes,scores] = detect(trainedModel,pmg);
    
    result=[];
    if size(bboxes,1)>0
        for k=1:size(bboxes,1)
            cx=round(bboxes(k,2)+bboxes(k,4)/2)*downsample;
            cy=round(bboxes(k,1)+bboxes(k,3)/2)*downsample;
            result=[result; round(cx),round(cy),scores(k)];
        end
        fprintf('# of Particles found: %d\n',size(result,1));
    else
        fprintf('**NO Particle FOUND on Complete Micrograph');
    end   
    predLoc=result;
end

% Removing duplicates centers using NMS (Non-maximal supression) 
function [predLocNMS] = nms(predLoc,supressionDiameter)
    %supressionRadius=ceil(supressionDiameter/2);
    supDiaSq=supressionDiameter*supressionDiameter;
    predLoc=sortrows(predLoc,[1 2]);
    predLocNMS=predLoc;
    n=size(predLoc,1);
    result=[];
    for i=1:n
        k=i;
        x=predLoc(k,1);y=predLoc(k,2);score=predLoc(k,3);
        if(score==-1)
            continue;
        end
        for j=max(1,i-100):n
           dist= (predLoc(j,1)-x)^2+(predLoc(j,2)-y)^2;
           if(dist<=supDiaSq && predLoc(j,3)>score)
               predLoc(k,3)=-1;
               k=j;
               x=predLoc(k,1);y=predLoc(k,2);score=predLoc(k,3);
           end
        end
        result=[result;k];        
    end    
    predLocNMS=predLocNMS(result,:);
end







