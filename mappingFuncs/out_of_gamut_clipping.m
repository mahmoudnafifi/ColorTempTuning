%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

%% clips out-of-gamut pixels
function [I,map] = out_of_gamut_clipping(I)
sz = size(I);
I = reshape(I,[],3);
map = ones(size(I,1),1);
map(I(:,1)>1 | I(:,2)>1 | I(:,3)>1 | I(:,1)<0 | I(:,2)<0 | I(:,3)<0)=0;
map = reshape(map,[sz(1),sz(2)]);
I(I>1)=1;
I(I<0)=0;
I = reshape(I,[sz(1),sz(2),sz(3)]);
end