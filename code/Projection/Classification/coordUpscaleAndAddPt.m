% Param:
% coordinate : [x1,y1;x2,y2;]
% upscale: 2 means upscale by 2 i.e point (4,5) --> (8,10)
% addNewPoint: true; if true means after upscalling add (upscale-1) points 
% in direction left,right, up down direction 
function [ coordinate ] = coordUpscaleAndAddPt(coordinate,upscale,addNewPoint)
    % X
    coordinate(:,1)=round(coordinate(:,1)*upscale);
    % Y
    coordinate(:,2)=round(coordinate(:,2)*upscale);
    addpoint=round(upscale-1);   
    if addNewPoint
        for dist=1:addpoint
            left=bsxfun(@plus,coordinate,[-dist,0]);
            right=bsxfun(@plus,coordinate,[dist,0]);
            up=bsxfun(@plus,coordinate,[0,-dist]);
            down=bsxfun(@plus,coordinate,[0,dist]);  
            coordinate=vertcat(coordinate,left,right,up,down);
        end
        coordinate=unique(coordinate,'rows');  
    end     
end

