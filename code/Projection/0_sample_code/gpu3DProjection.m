%% 3D Projection
%addpath(genpath('/home/khursheed/git/Cryp-EM/code/lib/3dviewer'));

%% Create 3D vol
% Create a simple hollow cube phantom
 cube = zeros(128,128,128);
 cube(17:112,17:112,17:112) = 1;
 cube(33:96,33:96,33:96) = 0;
 
 data=cube;
 dim=size(data);
 %% Creating Geometry
% Param: Y,X,Z
vol_geom=astra_create_vol_geom(dim(1),dim(2),dim(3));
%%
det_spacing_x=1.0;det_spacing_y=1.0;
det_row_count= ceil(sqrt(sum(dim.^2))) ; 
det_col_count=ceil(sqrt(sum(dim.^2))) ;
% Angle w.r.t y axis. Plane will rotate along Z axis
angles = linspace2(0, pi, 180); 
proj_geom=astra_create_proj_geom('parallel3d',det_spacing_x,det_spacing_y,...
    det_row_count,det_col_count,angles);

%% GPU. Take Projection
% Create projection data from this
[proj_id, proj_data] = astra_create_sino3d_cuda(data, proj_geom, vol_geom);
astra_mex_data3d('delete', proj_id);
%%
