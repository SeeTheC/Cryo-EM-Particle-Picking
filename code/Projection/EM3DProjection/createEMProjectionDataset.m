%% EMD 3D Projection
addpath(genpath('/home/khursheed/git/Cryp-EM/code/lib/3dviewer'));
addpath(genpath('MapFileReader/'));
%% Reading Emd virus
 dataNum = 5693;
 datasetPath='~/git/Dataset/EM';
 em1003File=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map');
 em1003 = mapReader(em1003File);
 em5693File=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
 em5693 = mapReader(em5693File);

 %%
 data=em5693;
 dim=size(data);
 
 %% 1. Creating Vol Geometry
% Param: Y,X,Z
vol_geom=astra_create_vol_geom(dim(1),dim(2),dim(3));

%% 2. Projection Geomerty

det_spacing_x=0.5;det_spacing_y=0.5;
det_row_count= ceil(sqrt(sum(dim.^2))) ; 
det_col_count=ceil(sqrt(sum(dim.^2))) ;
% Angle w.r.t y axis. Plane will rotate along Z axis
angles = linspace2(0, pi, 180); 

angles=[0,pi];

proj_geom=astra_create_proj_geom('parallel3d',det_spacing_x,det_spacing_y,...
    det_row_count,det_col_count,[0,pi]);

%% 3. GPU. Take Projection
% Create projection data from this
% dimension of proj_data = YxZxX i.e ColxAnglexRow
[proj_id, proj_data] = astra_create_sino3d_cuda(data, proj_geom, vol_geom);
astra_mex_data3d('delete', proj_id);

% Converting it into YxXxZ
projection = permute(proj_data,[1,3,2]);


%% Show Image

figure('name','EMD-5693: Angle-0 rad')
%ithProj=squeeze(proj_data(:,2,:))';
ithProj=projection(:,:,1);
ithProj=ithProj/max(ithProj(:)); % normalizing intensites value
imshow(ithProj);
title('\fontsize{10}{\color{magenta}EMD-5693: Angle-0 rad}');
colorbar,axis on, axis tight, xlabel('X-Axis'); ylabel('Y-Axis');

%%
a = projection(:,:,1);
b = projection(:,:,2);


%%
% save img
imwrite(ithProj,'EMD-5693.jpg');

