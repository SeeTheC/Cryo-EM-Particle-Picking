%% INIT 
server=0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

basepath=strcat(basepath,'/_data-Y,Z','v.10');
testPath=strcat(basepath,'/test');
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');
testRawPath= strcat(testPath,'/raw_img/','1_2.mat');

struct=load(testRawPath);
collage=struct.img;

struct=load(testCollagePath);
collage1=struct.img;
%% 
% Setting background to max value/2
% Intensity downscale=1
img=collage1;
img(img==0)=max(img(:))/2;
scale=1;
img1=img/scale;
img1=poissrnd(img1);
img=img1;
fprintf('Done..\n');
figure;
imshow(img,[]),
colorbar,impixelinfo;
imwrite((img-min(img(:)))/max(img(:)),'c1.jpg');

figure
subplot(1,2,1);
imshow(img,[]),title('Noisy Image'),colorbar;

subplot(1,2,2);
imshow(img-collage1,[]),title('Noise'),colorbar;

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
