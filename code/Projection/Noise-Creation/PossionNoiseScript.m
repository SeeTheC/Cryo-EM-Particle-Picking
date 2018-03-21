%% INIT 
server =0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

basepath=strcat(basepath,'/_data-Y,Z','v.10');
testPath=strcat(basepath,'/test');
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');
testRawPath= strcat(testPath,'/raw_img/','1.mat');

struct=load(testCollagePath);
collage=struct.img;
collage(collage==0)=50;
%%
figure;
imshow(collage,colormap(gray(120))),
impixelinfo;
colorbar,impixelinfo;
%% Adding Noise
img1=double(collage);
scale=10*1e12;
noiseImg =scale*imnoise(img1/scale,'poisson');
figure('name','noise');
imshow(noiseImg,[])
colorbar,impixelinfo;

%%
I = imread('2.jpg');J = rgb2gray(I);J = IMNOISE(J,'poisson')

%%
coin = im2double(imread('eight.tif'));
coin=coin;

scale=1e9;
figure
imshow(coin,[])
J = scale * imnoise(coin/scale, 'poisson'); 
imshow(J,[]);
%imwrite(J,'a1.jpg');
%%
scale=1e12;
img=double(coin);
for i=1:size(img,1)
    for j=1:size(img,2)
        img(i,j)=img(i,j)+poissrnd(img(i,j)*scale,1)/scale;
    end
end
fprintf('Done..\n');
figure;
imshow(img,[]);
%imwrite(img,'a2.jpg');

%%
img=coin*255;
scale=2;
img=img/scale;
for i=1:size(img,1)
    for j=1:size(img,2)
        img(i,j)=img(i,j)+poissrnd(img(i,j),1);
    end
end
%%
fprintf('Done..\n');
figure;
imshow(img,[]),
impixelinfo;
%imwrite((img-min(img(:)))/max(img(:)),'a2.jpg');


