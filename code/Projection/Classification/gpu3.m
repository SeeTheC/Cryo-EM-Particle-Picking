function [ output ] = gpu3()
%% INIT
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
function [ num ] = method1( idx )     
     cx=floor((idx-1)/W)+1;cy=mod(idx-1,W)+1;     
     if(cx<hStartIdx || cx> hEndIdx || cy<wStartIdx || cy>wEndIdx)
        num=0;return;
     end

     %[x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
     patch=collage([1:10]);
     %patch=patch*patch;
     
     num=collage(1,1);
end

%%
tic
fprintf('Init GPU array...');
%collage=mat; index=index;
collage=mat; index=gpuArray(index);
fprintf('Done...\n');
toc

tic
fprintf('Processing...');
b=arrayfun(@method1,index);
output=reshape(b,10,10)';
toc
%%

end
