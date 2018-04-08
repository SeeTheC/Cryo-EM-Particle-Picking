%% INIT 
server=0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

%basepath=strcat(basepath,'/_data-Y,Z','v.10');
%basepath=strcat(basepath,'/_data-proj-5693','v.20');background=30;
%basepath=strcat(basepath,'/_data-proj-2211','v.10');background=0.1;
basepath=strcat(basepath,'/_data-proj-5689','v.10');background=0.065;
%basepath=strcat(basepath,'/_data-proj-5762','v.10');background=0.1;

testPath=strcat(basepath,'/test');
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','21.mat');

struct=load(testCollagePath);
collage1=struct.img;
format short;
%% 
% Setting background to max value/2
% Intensity downscale=1
toScale=false;
if max(collage1(:))<10
    toScale=true;
end
img=collage1;
bgimg=img;
bgimg(bgimg<=background)=max(bgimg(:))/2;

if toScale
    img=bgimg*255;
else
    img=bgimg;
end
totalPixelvalue=sum(img(:));

scale=10;
img1=img/scale;
totalDownscalePixelvalue=sum(img1(:));

fprintf('TPV:%f t Downscale TPV:%f',totalPixelvalue,totalDownscalePixelvalue);
img1=poissrnd(img1);

if toScale
    img=img1./255;
else
    img=img1;
end

fprintf('Done..\n');

figure,imshow(img,[]),colorbar,impixelinfo;
imwrite((img-min(img(:)))/max(img(:)),'c1.jpg');

figure
subplot(1,2,1);
imshow(img,[]),title('Noisy Image'),colorbar;

subplot(1,2,2);
imshow(bgimg,[]),title('orginal'),colorbar,impixelinfo;

%% 2.

% Setting background to max value/2
% Intensity downscale=2
img=collage1;
img(img==0)=max(img(:))/2;
scale=2;
img2=img/scale;

img2=poissrnd(img2);

img=img2;
fprintf('Done..\n');
figure;
imshow(img,[]),
colorbar,impixelinfo;
imwrite((img-min(img(:)))/max(img(:)),'c2.jpg');

figure
subplot(1,2,1);
imshow(img,[]),title('Noisy Image'),colorbar;

subplot(1,2,2);
imshow(img-collage1,[]),title('Noise'),colorbar;
%% 3.
% Setting background to max value/3
% Intensity downscale=10
img=collage1;
img(img==0)=max(img(:))/2;
scale=10;
img3=img/scale;

img3=poissrnd(img3);

img=img3;
fprintf('Done..\n');
figure;
imshow(img,[]),
colorbar,impixelinfo;
imwrite((img-min(img(:)))/max(img(:)),'c3.jpg');

figure
subplot(1,2,1);
title('Noisy Image'),
imshow(img,[]),title('Noisy Image'),colorbar;

subplot(1,2,2);
imshow(img-collage1,[]),title('Noise'),colorbar;

%% 4.

% Setting background to max value/3
% Intensity downscale=2
img=collage1;
img(img==0)=max(img(:))/3;
scale=100;
img4=img/scale;

img4=poissrnd(img4);

img=img4;
fprintf('Done..\n');
figure;
imshow(img,[]),
colorbar,impixelinfo;
imwrite((img-min(img(:)))/max(img(:)),'c4.jpg');

figure
subplot(1,2,1);
title('Noisy Image'),
imshow(img,[]),title('Noisy Image'),colorbar;

subplot(1,2,2);
imshow(img-collage1,[]),title('Noise'),colorbar;
