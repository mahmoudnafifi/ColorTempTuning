%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

%% computes mapping functions for our target color temps
function M = computeMFs(in,target)
% in: 150x150x3 tiny image with current WB setting
% target: 150x150x3xn tiny images with the n target WB settings
M = zeros(size(target,4),34*3);
sz = size(target);
A = phi(reshape(double(imresize(in,[sz(1),sz(2)])),[],3));
for i = 1 : size(target,4)
    B = reshape(target(:,:,:,i),[],3);
    M (i,:) = reshape(A\B,1,[]);
end

