% LAB
%------------
%script to store frames of video for training (so as not to rely on
%avisynth)
addpath('../random_forest/')
addpath('../training/')

init_options_colourmodel_22;

video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
images = repmat(uint8(0),[opts.imgheight, opts.imgwidth, 3, length(opts.testingset)]);
%compute colour histogram for skin and body from reference image
colour_hist = ref_histogram(opts);
    
for i = 1:length(opts.testingset)
    %load images
    I=mre_avifile(video_path,opts.testingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    %add padding
    I = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
    %compute background histogram
    images(:,:,:,i) = uint8(compute_posterior(opts,I,colour_hist)*255);
end

save(sprintf('./frames/colourmodel/video%d/images.mat',opts.video_num),'-v7.3','images');
save(sprintf('./frames/colourmodel/video%d/testingset.mat',opts.video_num),'opts');

