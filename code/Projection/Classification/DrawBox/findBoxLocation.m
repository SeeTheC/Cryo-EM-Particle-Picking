function [X,Y] = findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,maxNoOfPartice)
    
 %% Init
    [H,W]=size(scoreCollage);    
    patchH=boxSize(1);patchW=boxSize(2);    
    halfPatchH=patchH/2;halfPatchW=patchW/2;
   
    hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
    wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
    fprintf('Init ...\n');
 %% Find location
     X=zeros(maxNoOfPartice,1);
     Y=zeros(maxNoOfPartice,1);
     particleCount=1;
     for r= hStartIdx:hEndIdx  
         fprintf('Row:%d \n',r);
        for c=wStartIdx:wEndIdx            
            cx=r;cy=c;
            s=scoreCollage(cx,cy);            
            if s>probThershold            
                [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,supressBoxSize);
                fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
                box=scoreCollage(x1:x2,y1:y2);
                [~,idx]=max(box(:));
                mr=mod(idx,supressBoxSize(1));
                mc=ceil(idx/supressBoxSize(1));
                locX=x1+mr-1;locY=y1+mc-1;
                if particleCount<=maxNoOfPartice
                    X(particleCount)=locX;
                    Y(particleCount)=locY;
                    particleCount=particleCount+1;
                    % Supress the values less than equal to max value
                    [x1,x2,y1,y2] = getPatchCoordinat(locX,locY,supressBoxSize);
                    if(x1<1)
                        x1=1;
                    end
                    if(y1<1)
                        y1=1;
                    end
                    if(x2>H)
                        x2=H;
                    end
                    if(y2>W)
                        y2=W;
                    end
                    fprintf('->x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);                                    
                    scoreCollage(x1:x2,y1:y2)=0;                    
                else
                    fprintf('ERROR: Particle count is greater than Max value...\n');
                    return;
                end                
            end
        end
     end
    
%%
    X=X(1:particleCount-1);Y=Y(1:particleCount-1);
end

