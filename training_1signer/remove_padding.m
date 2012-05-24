%script to remove padding from images
init_options_colourmodel_22_save;
load(sprintf('./frames/rgb/video%d/images.mat',opts.video_num));
datax = (opts.padding+1):(opts.padding+opts.stdimgwidth);
datay = (opts.padding+1):(opts.padding+opts.stdimgheight);
images = images(datay,datax,:,:);
save(sprintf('./frames/rgb/video%d/images.mat',opts.video_num),'-v7.3','images');
