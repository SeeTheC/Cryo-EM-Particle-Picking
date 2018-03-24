% It tries to find the probable location of the point where virus center
% can be, with its score (mostly probabilty)
% Param:
% minScore: minscore thershold    
% Return:
% location=[x1,y1,s1;...] where x1: x-axis,y1-axis & s1: score

function [location,particleCount] = findProbableLoc(scoreCollage,minScore)    
 %% Init
    [H,W]=size(scoreCollage);       
    fprintf('Init ...\n');
 %% Find location
     location=[]; %[x,y,s] where x: x-axis,y-axis & s: score
     particleCount=1;
     for r= 1:H
        for c=1:W            
            cx=r;cy=c;
            s=scoreCollage(cx,cy);            
            if s>minScore 
                location=vertcat(location,[cx,cy,s]);
                particleCount=particleCount+1;
            end
        end
     end     
end

