%the set of images specified by frame index
function images = load_images(opts)
    num_images = 0;
    for v_num = 1:length(opts.video_num)
        video_opts = load(sprintf('%svideo%d/trainingset.mat',opts.frames_dir ,opts.video_num(v_num)),'opts');
        num_images = num_images + length(video_opts.opts.trainingset);
    end
    images = repmat(uint8(0),[opts.imgheight,opts.imgwidth,opts.numchannels,num_images]);
    
    num_images = 0;
    for v_num = 1:length(opts.video_num)
        video_opts = load(sprintf('%svideo%d/trainingset.mat',opts.frames_dir ,opts.video_num(v_num)),'opts');
        I = load(sprintf('%svideo%d/images%d.mat',opts.frames_dir ,opts.video_num(v_num),opts.windowwidth),'images');
        id = length(video_opts.opts.trainingset);
        images(:,:,:,(num_images+1):(num_images+id)) = I.images;
        num_images = num_images + id;
    end
end