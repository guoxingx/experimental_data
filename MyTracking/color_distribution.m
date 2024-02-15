%-------------------------------------
function cd = color_distribution(imPatch, Nbins)

R_rate = 0.66;
G_rate = 0.33;
B_rate = 0.01;

b = floor(256/Nbins);
matrix_bin = floor(imPatch/b) + 1;
h=zeros(Nbins,1);

% since there is matlab function called bwdist,
% i want to make matrix 0 with 1 in the center,
% so i can calculate the distance of each pixel to the center with bwdist()
% then i should normalized the distance
center_imagePatch = round(size(imPatch)/2);
imagePatch_new = zeros(size(imPatch));
imagePatch_new(center_imagePatch(1), center_imagePatch(2)) = 1;

d_Center = bwdist(imagePatch_new);
dN_Center = (d_Center - min(d_Center(:)))/(max(d_Center(:)) - min(d_Center(:)));
Epanechnikov_profile=(2/pi)*(1-dN_Center.^2);

for u=1:Nbins
    whatever = ((matrix_bin - u)==0).*Epanechnikov_profile;    %multiplication for each element
    h(u,1) = sum(whatever(:));
end
cd = h/sum(h);

end