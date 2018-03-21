function [ num ] = testGpuMethod1( idx )
     global W;global hStartIdx;global hEndIdx;global wStartIdx;global wEndIdx;
     global patchDim;global collage;
     
     cx=floor((idx-1)/W)+1;cy=mod(idx-1,W)+1;     
     if(cx<hStartIdx || cx> hEndIdx || cy<wStartIdx || cy>wEndIdx)
        num=0;return;
     end
     [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim);
     patch=collage(x1:x2,y1:y2);
     %patch=patch*patch;
     num=sum(patch(:));
end

