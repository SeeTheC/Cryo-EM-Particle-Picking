% 2D Projection using Astra toolbolbox
%addpath(genpath('/home/khursheed/git/Cryp-EM/code/lib/astra'));
%% Load Image
phantomImg = phantom(256,256);

figure('name','Original: Phanton');
imshow(phantomImg,[]);
%% Create Geometry

imgDim=[256,256];
vol_geom=astra_create_vol_geom(imgDim(1),imgDim(2));

detectorGap=1.0;
noOfDetector= floor(256*sqrt(2)) + 22; % 22 is just a offset
angles=linspace2(0,pi,180);% creating 180 equally spaced angle between 0 to pi 
proj_geom= astra_create_proj_geom('parallel',detectorGap,noOfDetector,angles);

%% Creating 2D Projector
% Strip: The weight of a "ray/pixel pair" is given by the "area of the intersection" 
% of the pixel and the ray, considered as a strip with the same width as a 
% detector pixel.

proj_id = astra_create_projector('strip', proj_geom, vol_geom);

%% Creating Projection
[sinogram_id,sinogram]=astra_create_sino(phantomImg,proj_id);
astra_mex_data2d('delete', sinogram_id);
%%
figure('name','Phantom Projection'); 
imshow(sinogram, []);
axis on,axis tight
ylabel('Projection at angle (x radian)')
xlabel('Detector (space at 1)');
