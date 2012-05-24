 

h_img = imagesc(images(:,:,:,p.img_index(122))); axis image
hold on
 idx = find(p.img_index==p.img_index(122));
x = p.x(idx);
y = p.y(idx);
class = p.class(idx);
h_plot = plot(x(class~=8),y(class~=8),'b.');
h_title = title(num2str(1525));
for i = 1:(opts.numsampleimages*length(opts.video_num))
    set(h_img,'cdata',images(:,:,:,p.img_index((i-1)*opts.numwindows+1)));
    idx = find(p.img_index==p.img_index((i-1)*opts.numwindows+1)   );
    x = p.x(idx);
    y = p.y(idx);
    class = p.class(idx);
    set(h_plot,'xdata',x(class~=8),'ydata',y(class~=8));
    set(h_title,'string',num2str(i));
    pause(0.1)
    drawnow
end