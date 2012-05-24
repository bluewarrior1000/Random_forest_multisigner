%the set of images specified by frame index
function images = load_images(opts,frameindex)
    %preallocate images into memory
    
    %using repmat because  when using the function "zeros" matlab creates 
    %a double matrix before conterting it to uint8
    images = repmat(uint8(0),[opts.imgheight, opts.imgwidth, 3, length(frameindex)]);
%     images.frames = uint8(zeros(opts.imgheight, opts.imgwidth, 3, length(frameindex)));

    %load in video
    video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
    vi=mre_avifile(video_path,'info');

    %compute colour histogram for skin and body from reference image
    colour_hist = ref_histogram(opts);

    for i = 1:length(frameindex)
        %load images
        I=mre_avifile(video_path,frameindex(i)-1);
        I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
        %add padding
        I = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
        %compute background histogram
        images(:,:,:,i) = uint8(compute_posterior(opts,I,colour_hist)*255);
    end
end