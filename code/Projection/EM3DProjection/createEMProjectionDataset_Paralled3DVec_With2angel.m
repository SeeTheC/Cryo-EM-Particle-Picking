%% EMD 3D Projection
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
server = 0
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

%% 2. Projection Geometry
det_spacing_x=1;det_spacing_y=1;
det_row_count= ceil(sqrt(sum(dim.^2))) ; 
det_col_count=ceil(sqrt(sum(dim.^2))) ;
% Angle w.r.t y axis. Plane will rotate along Z axis
anglesY = linspace2(0, pi, 10); 
anglesZ = linspace2(0, pi, 10); 
%angles = [10, 10 + pi];
%angles=[0,pi];

%% 2.1 Description of Parrallel vec
% proj_geom = astra_create_proj_geom('parallel3d_vec',  det_row_count, det_col_count, vectors);
% Create a 3D parallel beam geometry specified by 3D vectors.
% 1. det_row_count: number of detector rows in a single projection
% 2. det_col_count: number of detector columns in a single projection
% 3  vectors: a matrix containing the actual geometry.
% 
% Each row of vectors corresponds to a single projection, and consists of:
% ( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
% ray : the ray direction
% d : the center of the detector
% u : the vector from detector pixel (0,0) to (0,1)
% v : the vector from detector pixel (0,0) to (1,0)

noOfAngles = numel(anglesY)*numel(anglesZ);
vectors=zeros(noOfAngles,12);
vidx=1;
for i=1:numel(anglesY)
    for j=1:numel(anglesZ)
        theta=anglesY(i);phi=anglesZ(j);
        % ray direction   
        vectors(vidx,1) = sin(phi)*sin(theta);
        vectors(vidx,2) = -sin(phi)*cos(theta);
        vectors(vidx,3) = cos(phi);

         % center of detector
         vectors(vidx,4) = 0;
         vectors(vidx,5) = 0;
         vectors(vidx,6) = 0;
         
         % vector from detector pixel (0,0) to (0,1)
         vectors(vidx,7) = cos(theta) * det_spacing_x;
         vectors(vidx,8) = sin(theta) * det_spacing_x;
         vectors(vidx,9) = 0;

         % vector from detector pixel (0,0) to (1,0)
         
         vectors(vidx,10) = -cos(phi)*sin(theta) * det_spacing_x;
         vectors(vidx,11) = cos(phi)*cos(theta) * det_spacing_x;
         vectors(vidx,12) = sin(phi) * det_spacing_y;
         vidx=vidx+1;
    end
end
% Test
%k=1,e=[vectors(k,1),vectors(k,2),vectors(k,3)],f=[vectors(k,7),vectors(k,8),vectors(k,9)],g=[vectors(k,10),vectors(k,11),vectors(k,12)],;
% 2.2 Proj

proj_geom_vec=astra_create_proj_geom('parallel3d_vec',det_row_count,det_col_count,vectors);

%% 3. GPU. Take Projection
% Create projection data from this
% dimension of proj_data = YxZxX i.e ColxAnglexRow
[proj_id, proj_data1] = astra_create_sino3d_cuda(data, proj_geom_vec, vol_geom);
astra_mex_data3d('delete', proj_id);

% Converting it into YxXxZ
projection1 = permute(proj_data1,[1,3,2]);


%% Show Image

if ~server
    figure('name','EMD-5693: Angle-0 rad')
    %ithProj=squeeze(proj_data(:,2,:))';
    ithProj=projection1(:,:,2)';
    ithProj=ithProj/max(ithProj(:)); % normalizing intensites value
    imshow(ithProj);
    title('\fontsize{10}{\color{magenta}EMD-5693: Angle-0 rad}');
    colorbar,axis on, axis tight, xlabel('X-Axis'); ylabel('Y-Axis');
    % View in 3d
    figure('name','EMD-5693: 3d')    
    imshow3D(projection1)
end

%% Save img
imwrite(uint8(ithProj),'EMD-5693.jpg');
save('projection.mat','ithProj');
%%