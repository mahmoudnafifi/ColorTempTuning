%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

%% applies matrix m to image I
function I_o = applyCorrection(I,m)
sz = size(I);
I_o = out_of_gamut_clipping(reshape(phi(reshape(...
    im2double(I),[],3)) * m,[sz(1),sz(2),sz(3)]));
end