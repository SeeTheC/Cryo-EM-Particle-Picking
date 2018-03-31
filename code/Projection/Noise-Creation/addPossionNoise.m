% Adds the Possion Noise to image
function [noisyImg] = addPossionNoise(img,downscaleIntesity,background)        
    img(img<=background)=max(img(:))/3;    
    img1=img/downscaleIntesity;
    noisyImg=poissrnd(img1);   
end

