function [ output ] = gpu4()
%% INIT
H=10; W=10;
patchDim=[3,3];
rng(1);
mat=reshape([1:H*W],H,W)';
index=[1:100];
patchH=patchDim(1);patchW=patchDim(2);    
halfPatchH=patchH/2;halfPatchW=patchW/2;
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);

%%
function [ num ] = method1( cellCol )   
     col=cellCol{1};
     col=col'*col;
     num=col(1);
end

%%
tic
fprintf('Init GPU array...');
collage=mat; index=index;
%collage=mat; index=gpuArray(index);

colmat=im2col(collage,patchDim);
dim=ones(1,size(colmat,2));
cellColl = mat2cell(colmat',dim);

fprintf('Done...\n');
toc

%%
tic
fprintf('Processing...');

b=arrayfun(@method1,cellColl);
output=reshape(b,H-patchH+1,W-patchW+1)';

fprintf('Done...\n');
toc
%%
end



