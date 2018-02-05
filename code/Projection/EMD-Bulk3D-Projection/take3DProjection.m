% Generate the 3D Projection for specified angle
% angles are in radian
% If angleAlong == Y then rotation is along Z
% If angleAlong == Z then angles is along Y
% By: Khursheed Ali. (Feb 2018) 
function [ projection ] =  take3DProjection(data,angles,angleAlong)
    %Init
    dim=size(data);
    detSpacingX=0.5;detSpacingY=0.5;
    det_row_count= ceil(sqrt(sum(dim.^2))); 
    det_col_count=ceil(sqrt(sum(dim.^2)));
    if angleAlong == 'Y'
        vectors=genProjVecForY(angles,detSpacingX,detSpacingY);
    elseif angleAlong == 'Z'
        vectors=genProjVecForZ(angles,detSpacingX,detSpacingY);
    end 
    
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

% Angle along Y so rotation is alog Z axis
function [vectors]= genProjVecForY(angles,detSpacingX,detSpacingY)
    % ( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
    % ray : the ray direction
    % d : the center of the detector
    % u : the vector from detector pixel (0,0) to (0,1)
    % v : the vector from detector pixel (0,0) to (1,0)
    noOfAngles = numel(angles);
    vectors=zeros(noOfAngles,12);
    for i=1:numel(angles)
        % ray direction
        theta=angles(i);
        vectors(i,1) = sin(theta);
        vectors(i,2) = -cos(theta);
        vectors(i,3) = 0;

         % center of detector
         vectors(i,4) = 0;
         vectors(i,5) = 0;
         vectors(i,6) = 0;

         % vector from detector pixel (0,0) to (0,1)
         vectors(i,7) = cos(theta) * detSpacingX;
         vectors(i,8) = sin(theta) * detSpacingX;
         vectors(i,9) = 0;

         % vector from detector pixel (0,0) to (1,0)
         vectors(i,10) = 0;
         vectors(i,11) = 0;
         vectors(i,12) = detSpacingY;
    end
end

% Angle along Z so rotation is alog Y axis
function [vectors]= genProjVecForZ(angles,detSpacingX,detSpacingY)
    % ( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
    % ray : the ray direction
    % d : the center of the detector
    % u : the vector from detector pixel (0,0) to (0,1)
    % v : the vector from detector pixel (0,0) to (1,0)
    noOfAngles = numel(angles);
    vectors=zeros(noOfAngles,12);
    for i=1:numel(angles)
        % ray direction
        theta=angles(i);
        vectors(i,1) = 0;
        vectors(i,2) = sin(theta);
        vectors(i,3) = -cos(theta);

         % center of detector
         vectors(i,4) = 0;
         vectors(i,5) = 0;
         vectors(i,6) = 0;

         % vector from detector pixel (0,0) to (0,1)
         vectors(i,7) = 0;
         vectors(i,8) = cos(theta) * detSpacingX;
         vectors(i,9) = sin(theta) * detSpacingX;

         % vector from detector pixel (0,0) to (1,0)
         vectors(i,10) = detSpacingY;
         vectors(i,11) = 0;
         vectors(i,12) = 0;
    end
end