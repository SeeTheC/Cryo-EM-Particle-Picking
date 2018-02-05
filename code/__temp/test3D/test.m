addpath(genpath('~/astra/matlab'))
addpath(genpath('../'))
dataNum = 5693;
file = sprintf('../../data/EMDB/EMD-%d/map/EMD-%d.map',dataNum, dataNum);
data = mapReader(file);

sizeCube = size(data,1);

vol_geom = astra_create_vol_geom(sizeCube, sizeCube, sizeCube);
angles = linspace2(0, pi, 180);
proj_geom = astra_create_proj_geom('parallel3d', 1.0, 1.0, 128, 192, angles);

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

% Set up the parameters for a reconstruction algorithm using the GPU
cfg = astra_struct('BP3D_CUDA');
cfg.ReconstructionDataId = rec_id;
cfg.ProjectionDataId = proj_id;


% Create the algorithm object from the configuration structure
alg_id = astra_mex_algorithm('create', cfg);

% Run 150 iterations of the algorithm
% Note that this requires about 750MB of GPU memory, and has a runtime
% in the order of 10 seconds.
astra_mex_algorithm('iterate', alg_id, 1000);

% Get the result
rec = astra_mex_data3d('get', rec_id);
figure, imshow(squeeze(rec(:,:,20)),[]);


% Clean up. Note that GPU memory is tied up in the algorithm object,
% and main RAM in the data objects.
astra_mex_algorithm('delete', alg_id);
astra_mex_data3d('delete', rec_id);
astra_mex_data3d('delete', proj_id);