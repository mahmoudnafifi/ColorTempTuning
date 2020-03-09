function [] = ResizeDNG(infile, outfile, scalefactor)

diary(fullfile('logs', ...
    ['ResizeDNG_', datestr(datetime, 'yyyymmdd-HHMMSS'), '.log']));

%scalefactor = .1;
% fn1 = fullfile('data', 'smartphone.dng');
% fn2 = fullfile('data', 'out.dng');

fn1 = infile;
fn2 = outfile;

t1 = Tiff(char(fn1), 'r');
t2 = Tiff(char(fn2), 'w');
if t1.getTag('BitsPerSample') <= 8 % raw should be at least 10 bps
    try
        offsets = getTag(t1, 'SubIFD');
        setSubDirectory(t1, offsets(1));
    catch 
    end
end

raw_data = read(t1);
[h, w] = size(raw_data);
new_h = round(h * scalefactor);
new_w = round(w * scalefactor);
if mod(new_h, 2) ~=0
    new_h = new_h + 1;
end
if mod(new_w, 2) ~=0
    new_w = new_w + 1;
end
new_data=ResizeRaw(raw_data, new_h, new_w);

ts = [];
ts.ImageLength = size(new_data,1);
ts.ImageWidth = size(new_data,2);
ts.Photometric = Tiff.Photometric.CFA;
ts.BitsPerSample = getTag(t1, 'BitsPerSample');
ts.SamplesPerPixel = getTag(t1, 'SamplesPerPixel');
ts.RowsPerStrip = 1;
ts.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
ts.Software = 'MATLAB';
t2.setTag(ts)
write(t2, new_data);
%rewriteDirectory(t2);
close(t2);


% t2 = Tiff(char(fn2), 'r+');
% for i = 0 : 65535
%     
%     % skip tags:
%     % ...
%     
%     tag1 = -1e-9;
%     tag2 = -1e-9;
%     try
%         tag1 = getTag(t1, i);
%     catch
%     end
%     if tag1 ~= -1e-9
%         %disp(tag1);
%         try
%             tag2 = getTag(t2, i);
%         catch
%         end
%         if tag2 ~= -1e-9
%             % tag already has a value
%         else
%             % copy tag from t1 to t2
%             setTag(t2, i, tag1);
%         end
%     end
% end
% rewriteDirectory(t2);
% close(t2);



% [status, t1tags] = system(['exiftool.exe -s ', fn1]);
% t1tags = strsplit(t1tags, '\n');

tagValPairs1 = GetAllTagValuePairs(fn1);
tagValPairs2 = GetAllTagValuePairs(fn2);

k = 30;

com = 'exiftool.exe -s ';
for i = 1 : size(tagValPairs1, 1)
    t1k = tagValPairs1{i, 1};
    t1v = tagValPairs1{i, 2};
    % skip
    if ismember(t1k, {'ExifToolVersion',...
                        'IFD0:ModifyDate', 'ModifyDate'...
                        'ExifIFD:DateTimeOriginal',...
                        'TIFF-EPStandardID',...
                        'IFD0:CFAPlaneColor',... % <<<<<<<<<
                        'IFD0:CFALayout',... % <<<<<<<<<<
                        'Aperture',...
                        'Megapixels',...
                        'ShutterSpeed',...
                        'FocalLength35efl',...
                        'LightValue'})
                    continue;
    end
    if ismember(t1k, tagValPairs2(:, 1))
        continue;
    end
%     disp([t1k, '::', t1v]);
%     [status, t2v] = system(['exiftool.exe -s -', t1k, ' ', fn2]);
%     if isempty(t2v)  % does not exist, add it to output exif
%         disp(['com: ', 'exiftool.exe -s -', t1k, '="', t1v, '" ', fn2]);
        if strcmp(t1k, 'CFARepeatPatternDim') ... % -IFD0:key="value"
                || strcmp(t1k, 'CFAPattern2') ...
                || strcmp(t1k, 'CFAPlaneColor') ...
                || strcmp(t1k, 'CFALayout') ...
                || strcmp(t1k, 'BlackLevelRepeatDim') ...
                || strcmp(t1k, 'BlackLevel') ...
                || strcmp(t1k, 'WhiteLevel') ...
                || strcmp(t1k, 'DefaultScale') ...
                || strcmp(t1k, 'DefaultCropOrigin') ...
                || strcmp(t1k, 'DefaultCropSize')                
%             [status, output] = system(...
%                 ['exiftool.exe -s -IFD0:', t1k, '="', t1v, '" ', fn2]);  
                com = [com, '-IFD0:', t1k, '="', t1v, '" '];
        else
%             [status, output] = system(...
%                 ['exiftool.exe -s -', t1k, '="', t1v, '" ', fn2]);
                com = [com, '-', t1k, '="', t1v, '" '];
        end
        
        if mod(i, k) == 0
            com = [com, ' ', fn2];
            disp(['com: ', com]);
            [status, output] = system(com);
            disp(['st: ', num2str(status), ', out: ', output]);
            com = 'exiftool.exe -s ';
        end
%         disp(['st: ', num2str(status), ', out: ', output]);
%     end
end

% take care of crop size and crop origin
% com = ['exiftool.exe -s -IFD0:', 'DefaultCropOrigin', ...
%     '="', '0 0', '" ', fn2];
com = [com, '-IFD0:', 'DefaultCropOrigin', '="', '0 0', '" '];
% disp(['com: ', com]);
% [status, output] = system(com);
% disp(['st: ', num2str(status), ', out: ', output]);

% com = ['exiftool.exe -s -IFD0:', 'DefaultCropSize', ...
%     '="', num2str(new_w), ' ', num2str(new_h) '" ', fn2];
com = [com, '-IFD0:', 'DefaultCropSize', '="', num2str(new_w), ' ', num2str(new_h), '" '];
% disp(['com: ', com]);
com = [com, ' ', fn2];
disp(['com: ', com]);
[status, output] = system(com);
disp(['st: ', num2str(status), ', out: ', output]);

end