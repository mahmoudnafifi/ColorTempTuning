%% Reference code for the paper:
% Mahmoud Afifi, Abhijith Punnappurath, Abdelrahman Abdelhamed, 
% Hakki Can Karaimer, Abdullah Abuolaim, and Michael S. Brown. Color 
% Temperature Tuning: Allowing Accurate Post-Capture White-Balance Editing.
% In the 27th Color and Imaging Conference, pp. 1-6(6), 2019.
%%

%% Kernel function
function O=phi(I)
O=[I,... %r,g,b
                I.*I,... %r2,g2,b2
                I(:,1).*I(:,2),I(:,1).*I(:,3),I(:,2).*I(:,3),... %rg,rb,gb
                I.*I.*I,... %r3,g3,b3
                I(:,1).*(I(:,2).^2),I(:,1).*(I(:,3).^2),... %r(g2),r(b2)
                I(:,2).*(I(:,3).^2),I(:,2).*(I(:,1).^2),... %g(b2),g(r2)
                I(:,3).*(I(:,2).^2),I(:,3).*(I(:,1).^2),... %b(g2),b(r2)
                I(:,1).*I(:,2).*I(:,3),... %rgb
                I.*I.*I.*I,... %r4,g4,b4
                (I(:,1).^3).*(I(:,2)),(I(:,1).^3).*(I(:,3)),... %(r3)g,(r3)(b)
                (I(:,2).^3).*(I(:,1)),(I(:,2).^3).*(I(:,3)),... %(g3)(r),(g3)(b)
                (I(:,3).^3).*(I(:,1)),(I(:,3).^3).*(I(:,2)),... %(b3)(r),(b3)(g)
                (I(:,1).^2).*(I(:,2).^2),(I(:,2).^2).*(I(:,3).^2),... %(r2)(g2),(g2)(b2)
                (I(:,1).^2).*(I(:,3).^2),... %(r2)(b2)
                (I(:,1).^2).*I(:,2).*I(:,3),... %(r2)gb
                (I(:,2).^2).*I(:,1).*I(:,3),... %(g2)rb
                (I(:,3).^2).*I(:,1).*I(:,2)] ;%(b2)rg
end