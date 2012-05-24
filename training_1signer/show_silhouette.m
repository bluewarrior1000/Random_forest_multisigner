%script to show silhouette tracking

init_options_colourmodel_22_save;
save_opts = load(sprintf('./frames/silhouette/video%d/trainingset.mat',opts.video_num));
addpath('../random_forest_1signer/')
opts.numchannels = 1;
opts.testingset = (save_opts.opts.trainingset(end)+1):2:(save_opts.opts.trainingset(end)+2000);
load(sprintf('%stomas_seg_videoNr%d.mat',opts.data_dir,opts.video_num));
images = uint8(128*double(seg(:,:,opts.testingset)));
images = padarray(images,[opts.padding, opts.padding, 0],'symmetric','both');

datax = (opts.padding+1):(opts.padding+opts.stdimgwidth);
datay = (opts.padding+1):(opts.padding+opts.stdimgheight);
figure
h_img = imagesc(images(datay,datax,1)); axis image
j = zeros(2,7);
hold on
clr = jet(7);
p = [];
for c = 1:(opts.numclasses-1)
     p(c) =  plot(j(1,c),j(2,c),'bo','markerfacecolor',clr(c,:), 'markersize',10);
end
box = opts.boundingbox;
for i = 1:size(images,3)
    dist = zeros(opts.numclasses,box(3)*box(4));
    for f = 1:opts.forest.numtrees
        dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(images(:,:,i)),8);
    end
    [j, dist] = get_joints(opts,dist);  
    j(1,:) = j(1,:) + box(1) -1;
    j(2,:) = j(2,:) + box(2) -1;
    j = j - opts.padding;
    for c = 1:(opts.numclasses-1)
    	set(p(c),'xdata',j(1,c),'ydata',j(2,c));
    end
    set(h_img,'cdata',images(datay,datax,i));
    pause(0.05)
    drawnow
end