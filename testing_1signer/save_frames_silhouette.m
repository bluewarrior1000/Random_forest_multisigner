% SILOUETTE
%------------
%script to store frames of video for training (so as not to rely on
%avisynth)


init_options_colourmodel_62_save;

load(sprintf('%stomas_seg_videoNr%d.mat',opts.data_dir,opts.video_num));
images = uint8(128*double(seg(:,:,opts.testingset)));

save(sprintf('./frames/silhouette/video%d/images.mat',opts.video_num),'-v7.3','images');
save(sprintf('./frames/silhouette/video%d/testingset.mat',opts.video_num),'opts');

