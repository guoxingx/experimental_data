% run flow

% read the images
clear
clc
close all
addpath('.\tools')
%%

% 视频路径
videoName = "videos/成纤维细胞-较快231029195212.avi";
v = VideoReader(videoName);

% 视频像素尺寸
vx = 1920; vy = 1080; 
fps = 30;         % 视频帧率
frame_step = 10;        % 每隔 idth 帧进行一次计算
dt = frame_step / fps;  % 每次计算处理的时间间隔
vxlim = 1920;     % 视频区域选取，x轴，单位是像素
vylim = 1080;     % 视频区域选取，y轴，单位是像素
circ_r = 111;     % 红圈半径，单位是像素点
pixsize = 1.335;  % 像素尺寸，单位um
magfn = 32.0;     % 放大倍率，计算速度时使用

keyframeid =  0;
f1 = figure; f2 = figure;
Center_preX = 0; Center_preY = 0;
PositionList = [];
slist = [];
GifSeq = [];
skip = 1;

% 截取 start - end 之间的帧数，默认不截取
frame_n_start = 300; frame_n_end = 1200; current_frame_n = 0;
while(hasFrame(v))
    current_frame_n = current_frame_n + 1;
    % 截取帧数
    if (frame_n_end > 0 && current_frame_n > frame_n_end)
        break;
    end
    
    % 读取单帧进行计算
    frame = readFrame(v);
    if (current_frame_n < frame_n_start)
        continue;
    end
    
    if(mod(current_frame_n, frame_step)==0)
        
        % 选取中心并画出红圈
        [Center_X, Center_Y] = Cal_Center(frame);
        figure(f1)
        imshow(frame);
        hold on
        viscircles([Center_X, Center_Y], circ_r, 'EdgeColor','r');
        
        % 选定视频尺寸
        xlim([0, vxlim]); ylim([0, vylim]);
        
        % 计算速度
        speed_x = (pixsize*(Center_X-Center_preX)/magfn)/ (dt * skip);
        speed_y = (pixsize*(Center_Y-Center_preY)/magfn)/ (dt * skip);
        
        % 舍弃速度为0或nan的帧
        if(keyframeid == 0)
            speed_x = 0; speed_y = 0;
        end
        if (isnan(speed_x) || isnan(speed_y))
            skip = skip + 1;
            continue;
        else
            skip = 1;
        end

        speed = sqrt(speed_x^2 + speed_y^2);
        text(200,200,["speed: "+num2str(speed)+" um/s", "  in x: "+num2str(speed_x)+" um/s", "  in y: "+num2str(speed_y)+" um/s", "frame:  "+current_frame_n]);
        
        Gif = getframe(f1);
        GifSeq = [GifSeq, Gif];
        PositionList = [PositionList;[Center_X,Center_Y]];
        slist = [slist, speed];
        Center_preX = Center_X;
        Center_preY = Center_Y;
        keyframeid = keyframeid + 1;    
    end
end

figure
plot(PositionList(:,1),PositionList(:,2),"Color",'r',"Marker",'*');
hold on
plot(PositionList(1,1),PositionList(1,2),"Color",'b',"Marker",'*');
% speed = sqrt(SpeedList(:,1).^2 + SpeedList(:,2).^2);

% 第一个速度为0
slist = slist(2:end);

% 如果方差过大，去掉一些过大的数据
if (var(slist) > mean(slist)^2)
    slist_purged = slist(find(slist<mean(slist)+sqrt(var(slist))));
    speed = mean(slist_purged);
else
    speed = mean(slist);
end


% 最终输出的gif文件路径
filename = videoName + '.speed-' + num2str(speed) + 'ums' + '.gif';

% figure
% plot(deltat*(1:size(speed,1)),speed)
% xlim([1,60])
    % gtflow = readFlowFile('data\other-gt-flow\Urban3\flow10.flo');
for idx = 1:size(GifSeq,2)
    imshow(frame2im(GifSeq(idx)))
    [A,map] = rgb2ind(frame2im(GifSeq(idx)),256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end
% % Grove2
% frame1 = imread('data\other-data\Grove2\frame10.png');
% frame2 = imread('data\other-data\Grove2\frame11.png');
% gtflow = readFlowFile('data\other-gt-flow\Grove2\flow10.flo');
% 
% % Grove3
% frame1 = imread('data\other-data\Grove3\frame10.png');
% frame2 = imread('data\other-data\Grove3\frame11.png');
% gtflow = readFlowFile('data\other-gt-flow\Grove3\flow10.flo');
% 
% % Hydrangea
% frame1 = imread('data\other-data\Hydrangea\frame10.png');
% frame2 = imread('data\other-data\Hydrangea\frame11.png');
% gtflow = readFlowFile('data\other-gt-flow\Hydrangea\flow10.flo');


% more data are included in the data folder


% gtflow(gtflow>1e9) = NaN;
%%

% parameters lambda = 10;  % you can try differnt value for different cases

% estimate optical flow using 
% uv = estimateHSflow(frame1,frame2,10);
% figure 
% subplot(2,2,1),imshow(uint8(frame1)) ,subplot(2,2,2),imshow(uint8(frame2))
% subplot(2,2,3),imshow(abs(uv(:,:,1))./max(max(abs(uv(:,:,1)))))
% subplot(2,2,4),imshow(abs(uv(:,:,2))./max(max(abs(uv(:,:,2)))))
% figure
% mesh(uv(:,:,1))
% figure
% mesh(uv(:,:,2))
% figure
% mesh(uv(:,:,1).^2+uv(:,:,2).^2)


function Mask = CalMask(frame)
    LAB = rgb2lab(255-frame);
    B = abs(LAB(:,:,3));
    B = uint8(255*B./max(max(B)));
    Mask = imbinarize(B);
    Mask = imfill(Mask,'holes');
    Mask = imclearborder(Mask,4);
    seD = strel('diamond',1);
    Mask = imerode(Mask,seD);
    Mask = imerode(Mask,seD);
    Mask = bwareaopen(Mask,5000);
end

function [Center_X,Center_Y] = Cal_Center(frame)
    Mask = CalMask(frame);
    frame = rgb2lab(frame);
    frame = abs(frame(:,:,3)).*Mask;
    H = size(frame,1);
    W = size(frame,2);
    u = 1:W;
    v = 1:H;
    [X,Y] = meshgrid(u,v);
    M00 = sum(sum(frame));
    M10 = sum(sum(X.*frame));
    M01 = sum(sum(Y.*frame));
    Center_X  = M10/M00;
    Center_Y  = M01/M00; 
end