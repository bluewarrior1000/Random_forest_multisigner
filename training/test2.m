init_options_lab_62;

video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
images = repmat(uint8(0),[opts.imgheight, opts.imgwidth, 3, length(opts.trainingset)]);

figure

for i = 1000:length(opts.trainingset)
    %load images
    I=mre_avifile(video_path,opts.trainingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    
    if i==1000
        h_img = imagesc(I); axis image
        hold on
        x = opts.joints(1,:,opts.trainingset(i));
        y = opts.joints(2,:,opts.trainingset(i));
        h_plot = plot(x,y,'bo','markersize',5,'markerfacecolor','w');
    else
        set(h_img,'cdata',I);
        x = opts.joints(1,:,opts.trainingset(i));
        y = opts.joints(2,:,opts.trainingset(i));
        set(h_plot,'xdata',x,'ydata',y);
        pause(0.8)
        drawnow
    end
end