clear
clc
close all
addpath('../Data/');
pixsize = 1.335;%um
magfn = 31.4; %放大倍率
% RubberWhale
v = VideoReader("../1.avi");
idth = 10; % 视频采样点
deltat = idth/60; % 采样间隔，帧率
id = 0; % video的序号
keyframeid =  0; %关键帧id
f1 = figure;
PreCenter = [0,0]; % ROI的中心，圆心
CurCenter = [0,0];
Radial = 0; %半径
imPatch = []; %前一帧的patch，参考帧patch
imPatch2 = []; % 当前帧的patch，当前帧patch
Nbins = 16; % 直方图的采样间隔
GifSeq = [];
while(hasFrame(v))
    frameshow = readFrame(v);
    frame = rgb2lab(frameshow);
    frame = abs(frame(:,:,3));
    frame = uint8(255*(frame./max(max(frame))));
    imshow(frame)
%     if(id==0)
%        [c,r] =  GetCircleMask(frame);
%        PreCenter = c;
%        Radial = r;
%        imPatch = extract_image_patch_center_size(frame, PreCenter, Radial);
%        TargetModel = color_distribution(imPatch, Nbins);
%     end
%     if(mod(id,idth)==0&&id>0)
%         figure(f1)
%         imshow(frameshow)
%         viscircles(CurCenter,Radial,'EdgeColor','r');
%         Gif = getframe(f1);
%         GifSeq = [GifSeq,Gif];
%         while(1)
%             imPatch = extract_image_patch_center_size(frame, PreCenter,Radial);
%     	    ColorModel = color_distribution(imPatch, Nbins);
%             rho = compute_bhattacharyya_coefficient(TargetModel, ColorModel);
%             weights = compute_weights_NG(imPatch, TargetModel, ColorModel, Nbins);
%             z = compute_meanshift_vector(imPatch, PreCenter, weights);
%     	    CurCenter = round(z);
%             imPatchtmp = extract_image_patch_center_size(frame, PreCenter,Radial);
%     	    ColorModel2 = color_distribution(imPatchtmp, Nbins);
%             rho2 = compute_bhattacharyya_coefficient(TargetModel, ColorModel2);
%             while(rho2<rho)
%                 CurCenter = (PreCenter+CurCenter)/2;
%                 imPatchtmp = extract_image_patch_center_size(frame, PreCenter,Radial);
%                 ColorModel2 = color_distribution(imPatchtmp, Nbins);
%                 % evaluate the Bhattacharyya coefficient
%                 rho2 = compute_bhattacharyya_coefficient(TargetModel, ColorModel2);
%             end
% 
%             % STEP 6
%             if norm(CurCenter-PreCenter) < 0.0001
%                 break
%             end
%             PreCenter = CurCenter;
%         end
%             keyframeid = keyframeid + 1;
%     end
    id = id+1;
end
filename = 'Tracking.gif'; % Specify the output file name
for idx = 1:size(GifSeq,2)
    imshow(frame2im(GifSeq(idx)))
    [A,map] = rgb2ind(frame2im(GifSeq(idx)),256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end
