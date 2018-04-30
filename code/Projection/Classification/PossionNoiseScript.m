%% INIT 
server =1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

basepath=strcat(basepath,'/_data-Y,Z','v.10');
testPath=strcat(basepath,'/test');
testCollagePath= strcat(testPath,'/collage1_6x6','/raw_img/','1.mat');

struct=load(testCollagePath);
collage=struct.img;


%%
coin = im2double(imread('eight.tif'));
coin=coin;

%scale=1e9;
figure
%imshow(coin,[])
%J = scale * imnoise(coin/scale, 'poisson'); 
%imshow(J,[]);
%imwrite(J,'a1.jpg');
%%

%{
scale=100;
img=coin;
for i=1:size(img,1)
    for j=1:size(img,2)
        img(i,j)=img(i,j)+poissrnd(img(i,j)*scale,1)/scale;
    end
end
fprintf('Done..\n');
figure;
%imshow(img/max(img(:)),[]);
imwrite(img/max(img(:)),'a2.jpg');
%}

scale=100/255;
img=coin*255;
for i=1:size(img,1)
    for j=1:size(img,2)
        img(i,j)=img(i,j)+poissrnd(img(i,j)*scale,1)/scale;
    end
end
fprintf('Done..\n');
figure;
%imshow(img/max(img(:)),[]);
imwrite((img-min(img(:)))/max(img(:)),'a2.jpg');
