% available temperatures:
% [1000;1500;2000;2500;3000;3500;4000;4500;5000;5500;6000;6500;7000;7500;
%  8000;8500;9000;9500;10000]

imfile = fullfile('data', 'out.dng');
temp = 2500;
[wb_raw, cst] = TempToWbAndCST(imfile, temp);

% sanity check: plot all RG chromaticity of all available temperatures
Rs = [];
Gs = [];
for t = [1000;1500;2000;2500;3000;3500;4000;4500;5000;5500;6000;...
        6500;7000;7500;8000;8500;9000;9500;10000]'
    [wb_raw, cst] = TempToWbAndCST(imfile, t);
    Rs(end+1) = wb_raw(1) / sum(wb_raw);
    Gs(end+1) = wb_raw(2) / sum(wb_raw);
end
plot(Rs, Gs); % looks like a planckian locus :)

% test
imname = 'out.dng';
imfile = fullfile('data', imname);
[raw, meta] = Load_Data_and_Metadata_from_DNG(imfile);
tone_im = run_pipeline(raw, meta, 'raw', 'srgb', [], meta.AsShotNeutral);
imwrite(tone_im, fullfile('data', [imname, '_', 'org.jpg']));
for t = [3000;4000;5500;6500;7500;]'
    disp(t);
    [wb_raw, cst] = TempToWbAndCST(imfile, t);
    tone_im = run_pipeline(raw, meta, 'raw', 'srgb', [], wb_raw, []);
    imwrite(tone_im, fullfile('data', [imname, '_', num2str(t), '.jpg']));
end
