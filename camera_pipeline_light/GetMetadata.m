function [metadata] = GetMetadata(filepath)

metadata = imfinfo(filepath);

% try 
%     if metadata.BitDepth ~= 16
%         for i = 1 : numel(metadata.SubIFDs)
%             metadata = metadata.SubIFDs{1, i};
%             if metadata.BitDepth == 16
%                 break;
%             end
%         end
%     end
% catch
% end

end