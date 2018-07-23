% This function will the "Predicted Location" and "True location on the micrograph"
% Param:
% visualDownsample: this downsample the big micrograph by the given amount for visual purpose.
% predictedLoc: Pred Loc "Matrix" 1st col: X coordinate & 2nd col: Y coordinate
% trueKnownLoc: True Loc "Table"  'col x':X coordinate & 'col y': Y coordinate

function [predImg,predTrueImg] = markCenterParticle(drawingConfig)
    %% INIT
    fprintf('Drawing Box...\n');   
    collage=drawingConfig.originalMg;
    visualDownsample=drawingConfig.visualDownsample;  
    %downscaleModel=drawingConfig.downscaleModel;
    predictedLoc=drawingConfig.predictedLoc;
    trueKnownLoc=drawingConfig.trueKnownLoc;
    savepath=drawingConfig.savepath;
    
    noOfPredLoc=size(predictedLoc,1);  
    noOfTrueLoc=size(trueKnownLoc,1);
    img=imresize(collage,1/visualDownsample);    
    img=img-min(img(:));
    img=img/max(img(:));

    
    %% Mark center at Predicted location      
    fprintf("Marking center at Pred Loc...\n");

    lineWidth=2;    markerSize=2;    predictColor='red';
    sizeOfImg=size(img);
    for r= 1:noOfPredLoc
        cx=predictedLoc(r,1)/visualDownsample;cy=predictedLoc(r,2)/visualDownsample;
        if(cx>sizeOfImg(1) || cy>sizeOfImg(2))
            continue;
        end 
        img=insertThickMarker(img,[cx,cy],markerSize,lineWidth,predictColor);
    end
    fprintf('Done.\n');
    %figure,imshow(img,[]);
    %title({'\fontsize{10}{\color{magenta}RandomForest 2000x2000 Micrograph}','\fontsize{10}{\color{red}[Downsampled by 8 for better visualization]}'});
    % Save Center mark
    imwrite(img,strcat(savepath,'/Predicted.png'));
    predImg=img;  
    %% % Drawing True Center
    fprintf('Marking True Center...\n');
    img1=img;
    lineWidth=2;    markerSize=1;    predictColor='green'; 
    sizeOfImg=size(img1);
    for idx=1:noOfTrueLoc
        row=trueKnownLoc(idx,:);
        cx=row.x/visualDownsample;cy=row.y/visualDownsample;
        if(cx>sizeOfImg(1) || cy>sizeOfImg(2))
            continue;
        end        
        %cx=cx/visualDownsample;cy=cy/visualDownsample;
        img1=insertThickMarker(img1,[cx,cy],markerSize,lineWidth,predictColor);      
    end

    fprintf('Done.\n');
    % Show result
    %figure,
    %imshow(img1,[]);
    %title({'\fontsize{10}{\color{magenta} SVM: Green->true & Re->predicted 2000x2000 Micrograph}','\fontsize{10}{\color{red}[Downsampled by 8 for better visualization]}'});
    
    % Save Center mark
    imwrite(img1,strcat(savepath,'/True_and_Predicted.png'));
    predTrueImg=img1;

end

