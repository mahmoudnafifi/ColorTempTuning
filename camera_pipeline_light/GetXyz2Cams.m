function [xyz2cam1, xyz2cam2] = GetXyz2Cams(metadata)
%GETCSTS Extract two CST mtrices from DNG metadata



% SHOULD WE INVERT THE CSTs?????????

%NOTE: CSTs found in DNG metadata map FROM XYZ TO CAMERA (not from camera
%to xyz). 
%CSTs are stored in row-scan order. 
%For convenience, this function returns their inverse that maps 
%FROM CAMERA TO XYZ.

try
    xyz2cam1 = reshape(metadata.ColorMatrix1, 3, 3)';
    cc1 = reshape(metadata.CameraCalibration1, 3, 3)';
    xyz2cam1 =  cc1 * xyz2cam1;
    ab = diag(metadata.AnalogBalance);
    xyz2cam1 =  ab * xyz2cam1;
    
catch
    warning('something wrong while reading xyz2cam 1');
end
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,2),1,3); % Normalize rows to 1
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,1),3,1); % Normalize columns to 1
% cst1 = xyz2cam ^ -1; % inverse
try
%     xyz2cam9 = metadata.ColorMatrix2;
%     xyz2cam9 = metadata.CameraCalibration2 .* xyz2cam9;
%     xyz2cam2 = reshape(xyz2cam9,3,3)';
%     xyz2cam2 = diag(metadata.AnalogBalance) .* xyz2cam2;
    xyz2cam2 = reshape(metadata.ColorMatrix2, 3, 3)';
    cc2 = reshape(metadata.CameraCalibration2, 3, 3)';
    xyz2cam2 =  cc2 * xyz2cam2;
    ab = diag(metadata.AnalogBalance);
    xyz2cam2 =  ab * xyz2cam2;
    
catch
    warning('something wrong while reading xyz2cam 2');
end
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,2),1,3); % Normalize rows to 1
% xyz2cam = xyz2cam ./ repmat(sum(xyz2cam,1),3,1); % Normalize columns to 1
% cst2 = xyz2cam ^ -1; % inverse

end

