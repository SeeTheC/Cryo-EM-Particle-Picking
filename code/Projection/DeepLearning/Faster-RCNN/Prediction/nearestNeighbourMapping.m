function [result,correctlyPredCount,trueCount,totalPredLoc] = nearestNeighbourMapping(trueKnownCoord,predLoc,nnThreshold,dimension)
    %% Init
    noOfTrueLoc=size(trueKnownCoord,1);
    totalPredLoc=size(predLoc,1);   
    H=dimension(1);W=dimension(2);
    %% Process
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
        noOfPredLoc=size(predLoc,1);
        if isempty(predLoc)
            continue;
        end
        %fprintf('noOfPredLoc:%d\n',noOfPredLoc);        
        for pIdx=1:noOfPredLoc
            px=predLoc(pIdx,1);py=predLoc(pIdx,2);
            if(px<1 || py <1)
                continue;
            end
            dist=norm([px-tx,py-ty]);
            if dist<minDist && dist<nnThreshold
                minIdx=pIdx;
                minDist=dist;
            end
        end
        if(minIdx ~=0)
            px=predLoc(minIdx,1);py=predLoc(minIdx,2);
            correctlyPredCount=correctlyPredCount+1;
            result=[result;tx,ty,px,py,minDist];
            predLoc(minIdx,:)=[];
        else
            result=[result;tx,ty,-1,-1,Inf];                       
        end
    end
   
end

