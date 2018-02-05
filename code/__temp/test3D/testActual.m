addpath(genpath('~/astra/matlab'))
addpath(genpath('../'))
dataNum = 5693;
file = sprintf('../../data/EMDB/EMD-%d/map/EMD-%d.map',dataNum, dataNum);
data = mapReader(file);

sizeCube = size(data,1)

vol_geom = astra_create_vol_geom(sizeCube, sizeCube, sizeCube);
angles = linspace2(0, pi, 180);
proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, 192, 192, angles);
data(:,:,100)
imwrite(data(:,:,100)/max(max(data(:,:,100))),'orig.jpg');
% Create a simple hollow cube phantom
% cube = zeros(128,128,128);
% cube(17:112,17:112,17:112) = 1;
% cube(33:96,33:96,33:96) = 0;

% Create projection data from this
[proj_id, proj_data] = astra_create_sino3d_cuda(data, proj_geom, vol_geom);

% Display a single projection image
figure, imshow(squeeze(proj_data(:,20,:))',[])

% Create a data object for the reconstruction
rec_id = astra_mex_data3d('create', '-vol', vol_geom);

[id, reconVol] = astra_create_backprojection3d_cuda(proj_data, proj_geom, vol_geom);

imwrite(reconVol(:,:,100)/max(max(reconVol(:,:,100))),'recon.jpg');

% disp(data(:,:,10)-reconVol(:,:,10))

% Create a simple hollow cube phantom

% Set up the parameters for a reconstruction algorithm using the GPU
% cfg = astra_struct('BP3D_CUDA');
% cfg.ReconstructionDataId = rec_id;
% cfg.ProjectionDataId = proj_id;

