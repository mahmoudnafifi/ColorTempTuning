function [tagValPairs] = GetAllTagValuePairs(filename)

tagValPairs = {};

[status, taglines] = system([fullfile('camera_pipeline_light','exiftool.exe -s '), filename]);
taglines = strsplit(taglines, '\n');

for i = 1 : length(taglines) - 1
    tag1keyval = strsplit(taglines{i}, ':');
    t1k = strtrim(tag1keyval{1});
    t1v = strtrim(tag1keyval{2});
    tagValPairs{i, 1} = t1k;
    tagValPairs{i, 2} = t1v;
end
end