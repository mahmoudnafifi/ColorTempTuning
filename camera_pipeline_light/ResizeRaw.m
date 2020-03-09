function [res] = ResizeRaw(raw, newh, neww)

res4ch = zeros(newh / 2, neww / 2, 4, class(raw));
raw4ch = RawTo4Channels(raw);
for i = 1 : 4
    res4ch(:, :, i) = imresize(raw4ch(:, :, i), [newh / 2, neww / 2]); % , 'method', 'nearest'
end
res = RawFrom4Channels(res4ch);

end

