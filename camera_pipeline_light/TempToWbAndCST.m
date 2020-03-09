%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

function [wb_raw, xyz2cam] = TempToWbAndCST(metadata, temp)
%TEMPTOWBANDCST Calculate image-specific WB and CST based on a given 
%illuminant temperature
cct1 = 6500; % D65, DNG code = 21
cct2 = 2500; % A, DNG code = 17
[xyz2cam1, xyz2cam2] = GetXyz2Cams(metadata); % these map from camera to XYZ
% interpolation weight
cct1inv = 1 / cct1;
cct2inv = 1 / cct2;
tempinv = 1 / temp;
g = (tempinv - cct2inv) / (cct1inv - cct2inv);
h = 1 - g;
if g < 0, g = 0; end
if h < 0, h = 0; end
if h > 1, h = 1; end

xyz2cam = g .* xyz2cam1 + h .* xyz2cam2;
wb_xyz = TempToXyz(temp);
wb_raw = (xyz2cam) * wb_xyz';
wb_raw = wb_raw ./ wb_raw(2); % make G = 1
end

