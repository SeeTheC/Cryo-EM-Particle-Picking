function [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchDim)
    patchH=patchDim(1);patchW=patchDim(2);   
    halfPatchH=patchH/2;halfPatchW=patchW/2;
    ispatchHOdd= mod(patchH,2); ispatchWOdd= mod(patchW,2);
    if ~ispatchHOdd
        x1=cx -floor(halfPatchH) + 1; x2 = cx + floor(halfPatchH);
    else
        x1=cx -floor(halfPatchH); x2 = cx + floor(halfPatchH);   
    end

    if ~ispatchWOdd
        y1=cy -floor(halfPatchW) + 1; y2 = cy + floor(halfPatchW);
    else
        y1=cy -floor(halfPatchW); y2 = cy + floor(halfPatchW);   
    end
      
end