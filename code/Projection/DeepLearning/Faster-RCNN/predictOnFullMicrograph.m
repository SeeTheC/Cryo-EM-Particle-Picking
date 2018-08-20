function [predLoc] = predictOnFullMicrograph(trainedModel,micrograph,downsample)
    %% Init
    
    mgMaxHW=1000;
    fprintf('Init Done.\n');
    %% Processing Large micrograph by dividing it into smaller one.    
    micrograph=micrograph-min(micrograph(:));
    micrograph=micrograph/max(micrograph(:));    
    imwrite(micrograph,strcat('temp.jpg'));
    micrograph = imread('temp.jpg');
    
    [mgH,mgW]=size(micrograph);
    mgIdx=1;
    nH=floor(mgH/mgMaxHW);
    nW=floor(mgW/mgMaxHW);
    result=[];
    for i=1:nH
        offsetX=(i-1)*mgMaxHW;
        x1=offsetX+1;x2=mgMaxHW*i;
        if i==nH
            x2=mgH;
        end
        for j=1:nW
            offsetY=(j-1)*mgMaxHW;
            y1=offsetY+1;y2=mgMaxHW*j;
            if j==nW
                y2=mgW;
            end
            patch=micrograph(x1:x2,y1:y2);   
            patch=imresize(patch,1/downsample);            
            % Predict location
            [bboxes,scores] = detect(trainedModel,patch);
            if size(bboxes,1)>0
                for k=1:size(bboxes,1)
                    cx=round(bboxes(k,2)+bboxes(k,4)/2)*downsample;
                    cy=round(bboxes(k,1)+bboxes(k,3)/2)*downsample;
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

