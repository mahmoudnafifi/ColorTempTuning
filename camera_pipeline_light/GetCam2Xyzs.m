function [cam2xyz1, cam2xyz2] = GetCam2Xyzs(metadata)
%GETCSTS Extract two CST mtrices from DNG metadata



% SHOULD WE INVERT THE CSTs?????????

%NOTE: CSTs found in DNG metadata map FROM XYZ TO CAMERA (not from camera
%to xyz). 
%CSTs are stored in row-scan order. 
%For convenience, this function returns their inverse that maps 
%FROM CAMERA TO XYZ.

xyz2cam9=metadata.ColorMatrix1;
xyz2cam1=reshape(xyz2cam9,3,3)';
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,2),1,3); % Normalize rows to 1
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,1),3,1); % Normalize columns to 1
cam2xyz1 = xyz2cam1 ^ -1; % inverse

xyz2cam9=metadata.ColorMatrix2;
xyz2cam2=reshape(xyz2cam9,3,3)';
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,2),1,3); % Normalize rows to 1
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,1),3,1); % Normalize columns to 1
cam2xyz2 = xyz2cam2 ^ -1; % inverse

end

