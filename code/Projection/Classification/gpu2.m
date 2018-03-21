clear all;
fprintf('GPU-Array-Patch prcocess');
range=10;
%g = gpuDevice(1);
%mat= gpuArray.rand(1,range*range);
%indexArray=gpuArray([1:fange*range]);

global H;global W;
global hStartIdx;global hEndIdx;global wStartIdx;global wEndIdx;
global patchDim;global collage;

%% Init
H=10; W=10;
patchDim=[3,3];
rng(1);
mat=randi([1,10],10,10);
index=[1:100];
patchH=patchDim(1);patchW=patchDim(2);    
halfPatchH=patchH/2;halfPatchW=patchW/2;
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);

%%
collage=mat;
index=index;
b=arrayfun(@testGpuMethod1,index);
bt=reshape(b,10,10)';
%%

%%