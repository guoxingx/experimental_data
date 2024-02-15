function imPatch = extract_image_patch_center_size(I, c, r)
% This function extract an image patch in image I given the center and size of the ROI

VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);
y = c(2)-r;
x = c(1)-r;
y2 = round(min(VIDEO_HEIGHT, y+2*r+1));
x2 = round(min(VIDEO_WIDTH, x+2*r+1));
y1 = round(max(y, 1));
x1 = round(max(x, 1));
t = linspace(0, 2*pi, 50);   %# approximate circle with 50 points
BW = poly2mask(r*cos(t)+c(1), r*sin(t)+c(2), VIDEO_HEIGHT, VIDEO_WIDTH);
I= I.*uint8(BW);
imPatch = I(y1:y2, x1:x2, :);
end