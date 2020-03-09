function [ raw_data, metadata ] = Load_Data_and_Metadata_from_DNG( image_name )
%Load_Data_and_Metadata_from_DNG Reads and returns raw image data and 
% metadata from DNG file "image_name"

    t = Tiff(char(image_name), 'r');
    if t.getTag('BitsPerSample') <= 8 % raw should be at least 10 bps
        try
            offsets = getTag(t, 'SubIFD');
            %offsets = t.TagID.SubIFD;
            setSubDirectory(t, offsets(1));
            %setDirectory(t,offsets(1));
        catch 
        end
    end
    raw_data = read(t);
    close(t);
    
    %metadata = imfinfo(char(image_name));
    metadata = GetMetadata(char(image_name));
    
    tagValuePairs = GetAllTagValuePairs(char(image_name));
    metadata.extra = [];
    for i = 1 : size(tagValuePairs, 1)
        try
            metadata.extra.(tagValuePairs{i, 1}) = tagValuePairs{i, 2};
        catch
        end
    end
end

