function [ fourchan ] = RawTo4Channels( raw )
%RAWTO4CHANNELS Summary of this function goes here
%   Detailed explanation goes here

[h,w] = size(raw);

fourchan = zeros(h / 2, w / 2, 4, class(raw));

idx = [1,1; 1,2; 2,1; 2,2];

for c=1:4
    %try
        fourchan(:,:,c) = raw(idx(c,1):2:end, idx(c,2):2:end);
    %catch
        % not necessary
        %sz = size(raw(idx(c,1):2:end, idx(c,2):2:end));
        %fourchan(1:sz(1),1:sz(2),c) = raw(idx(c,1):2:end, idx(c,2):2:end);
    %end
end


end

