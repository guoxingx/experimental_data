function [c,r] = GetCircleMask(I)
    figure(1);
    imshow(I)
    [x,y] = ginput(2);
    cx = x(1);
    cy = y(1);
    r = sqrt((x(1)-x(2))^2+(y(1)-y(2))^2);
    c = [cx,cy];
end


