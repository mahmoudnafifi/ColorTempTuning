%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

function [imSrgbFull, resizedSrgbImages] = camera_pipeline_light(...
    dngFilename, selected_temp, targetSize, temperatures)

if isempty(temperatures)
    temperatures = [2500, 4000, 5500, 7000, 8500]; %our target color temps
end

resizedSrgbImages = zeros(...
    targetSize, targetSize, 3, numel(temperatures), 'single');

[raw, metadata] = Load_Data_and_Metadata_from_DNG(dngFilename);
raw = CropActiveArea(raw, metadata);
rawSmall = ResizeRaw(raw, targetSize, targetSize);

% full image
[wbRaw, xyz2cam] = TempToWbAndCST(metadata, selected_temp);
imSrgbFull = run_pipeline(raw, metadata, 'raw', 'tone', [], ...
    wbRaw, xyz2cam);
    
for i = 1 : numel(temperatures)
    
    t = temperatures(i);
    [wbRaw, xyz2cam] = TempToWbAndCST(metadata, t);
    imSrgbSmall = run_pipeline(rawSmall, metadata, 'raw', 'tone', [], ...
        wbRaw, xyz2cam);
    resizedSrgbImages(:, :, :, i) = imSrgbSmall;
end

end