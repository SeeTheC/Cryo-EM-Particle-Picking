% Generate the 3D Projection for specified angle
% angles are in radian
% By: Khursheed Ali. (March 2018) 
function [ projection ] =  take3DProjectionWith2Angles(data,anglesY,angleZ)
    %Init
    dim=size(data);
    detSpacingX=0.5;detSpacingY=0.5;
    det_row_count= ceil(sqrt(sum(dim.^2))); 
    det_col_count=ceil(sqrt(sum(dim.^2)));
    vectors=genProjVec(anglesY,angleZ,detSpacingX,detSpacingY);
    
    % 1. Creating Vol Geometry
    % Param: Y,X,Z
    vol_geom=astra_create_vol_geom(dim(1),dim(2),dim(3));
    % 2. Projection Gemetry
    proj_geom_vec=astra_create_proj_geom('parallel3d_vec',det_row_count,det_col_count,vectors);
    
    % 3. Take Projection using  GPU.
    % Dimension of proj_data = YxZxX i.e ColxAnglexRow
    [proj_id, proj_data] = astra_create_sino3d_cuda(data, proj_geom_vec, vol_geom);
    astra_mex_data3d('delete', proj_id);
    
    % 4. Converting it into XxYxZ
    projection = permute(proj_data,[3,1,2]);    
end

% Angle along Y, with angle along Z as angleZ
function [vectors]= genProjVec(angles,angleZ,detSpacingX,detSpacingY)
    % ( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
    % ray : the ray direction
    % d : the center of the detector
    % u : the vector from detector pixel (0,0) to (0,1)
    % v : the vector from detector pixel (0,0) to (1,0)
    noOfAngles = numel(angles);
    vectors=zeros(noOfAngles,12);
    phi=angleZ;
    for vidx=1:numel(angles)
         theta=angles(vidx);
          % ray direction   
        vectors(vidx,1) = sin(phi)*sin(theta);
        vectors(vidx,2) = -sin(phi)*cos(theta);
        vectors(vidx,3) = cos(phi);

         % center of detector
         vectors(vidx,4) = 0;
         vectors(vidx,5) = 0;
         vectors(vidx,6) = 0;
         
         % vector from detector pixel (0,0) to (0,1)
         vectors(vidx,7) = cos(theta) * detSpacingX;
         vectors(vidx,8) = sin(theta) * detSpacingX;
         vectors(vidx,9) = 0;

         % vector from detector pixel (0,0) to (1,0)
         
         vectors(vidx,10) = -cos(phi)*sin(theta) * detSpacingX;
         vectors(vidx,11) =  cos(phi)*cos(theta) * detSpacingX;
         vectors(vidx,12) = sin(phi) * detSpacingY;
         vidx=vidx+1;
    end
end

