% available temperatures:
% [1000;1500;2000;2500;3000;3500;4000;4500;5000;5500;6000;6500;7000;7500;
%  8000;8500;9000;9500;10000]

warning('off')

imNames = {...
    'a0478-dgw_014_CONV.dng',...
    'a0727-07-11-11-at-11h53m38s-_MG_4569_CONV.DNG',...
    'Canon1DsMkIII_0068_CONV.dng',...
    'NikonD5200_0187_CONV.dng',...
    'smartphone.dng'...
    };
    

for k = 1 : numel(imNames)
    
    disp(['Processing image # ', num2str(k)]);
    imname = imNames{k};
    dngFilename = fullfile('data', imname);
    %targetHeight = 300;
    %targetWidth = 400;
    %temperatures = [3000;4000;5500;6500;7500;]';
    temperatures = [2000,2850,3800,5500,6500,7500,10000];
    
    selected_temp = 3999;
    targetSize = 250;
    
    % [original, downsampled] = camera_pipeline ( dng_file_path, selected_temp, downsampled_size);
    [imSrgbFull, resizedSrgbImages] = camera_pipeline(...
        dngFilename, selected_temp, targetSize);

    imwrite(uint8(imSrgbFull), fullfile('data', [imname, '_', 'org', '.jpg']));
    for i = 1 : numel(temperatures)
        smallImage = resizedSrgbImages(:, :, :, i); % 0-255 single
        imwrite(uint8(smallImage), fullfile('data', ...
            [imname, '_', num2str(temperatures(i)), '.jpg']));
    end
end


