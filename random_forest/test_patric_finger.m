init_options
video_path = sprintf('%s%s',opts.video_dir,opts.video_filename);
    vi=mre_avifile(video_path,'info');
% P = zeros(size(fingerPosMat));
% P(:,[1 3]) = fingerPosMat(:,[1 3])*3 +55;
% P(:,[2 4]) = fingerPosMat(:,[2 4])*3 +385;

I=mre_avifile(video_path,1);
I=mre_resizebilinear(I,203,360,true);
figure
h_img = imagesc(I);
axis image
% hold on
% P = P*0.5;
% p_left= plot(P(1,2),P(1,1),'bo','markerfacecolor','b');
% p_right= plot(P(1,4),P(1,3),'ro','markerfacecolor','r');


for i = 1:5:43000
    I=mre_avifile(video_path,i);
    I=mre_resizebilinear(I,203,360,true);
    set(h_img,'cdata',I);
%     set(p_left,'xdata',P(i,2),'ydata',P(i,1));
%     set(p_right,'xdata',P(i,4),'ydata',P(i,3));
    pause(0.05)
    drawnow
end