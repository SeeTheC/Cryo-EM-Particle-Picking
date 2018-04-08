% Adds the Possion Noise to image
function [noisyImg] = addPossionNoise(img,downscaleIntesity,background)  
    %% Init
    % scaling intensities, if it lies below 10 mostly it will from 0 to 2 
    toScale=false;
    if max(img(:))<10
        toScale=true;
    end
    if toScale
        img=img.*255;
    end
    %% Add noise
    img(img<=background)=max(img(:))/3;    
    img1=img/downscaleIntesity;
    noisyImg=poissrnd(img1);   
    if toScale
        noisyImg=noisyImg./255;
    end
end

