% Print thick marker on image
function [outImg] = insertThickMarker(img,loc,markerSize,lineWidth,color)
    cx=loc(1);cy=loc(2);
    img=insertMarker(img,[cy,cx],'x','color',color,'size',markerSize);    
    for w=1:lineWidth-1
        img=insertMarker(img,[cy-w,cx],'x','color',color,'size',markerSize); 
        img=insertMarker(img,[cy,cx-w],'x','color',color,'size',markerSize);    
        img=insertMarker(img,[cy+w,cx],'x','color',color,'size',markerSize);    
        img=insertMarker(img,[cy,cx+w],'x','color',color,'size',markerSize);    
    end
    outImg=img;
end

