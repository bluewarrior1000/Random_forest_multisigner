% LAB
%------------
%script to store frames of video for training (so as not to rely on
%avisynth)


init_options_colourmodel_59_save;

video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
images = repmat(uint8(0),[opts.stdimgheight, opts.stdimgwidth, 3, length(opts.trainingset)]);

for i = 1:length(opts.trainingset)
    %load images
    I=mre_avifile(video_path,opts.trainingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    %add padding
%     I = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
    %compute background histogram
    images(:,:,:,i) = I;
%     keyboard
end

save(sprintf('./frames/rgb/video%d/images.mat',opts.video_num),'-v7.3','images');
save(sprintf('./frames/rgb/video%d/trainingset.mat',opts.video_num),'opts');

