% SILOUETTE
%------------
%script to store frames of video for training (so as not to rely on
%avisynth)


init_options_colourmodel_61;

load(sprintf('%stomas_seg_videoNr%d.mat',opts.data_dir,opts.video_num));
images = uint8(128*double(seg(:,:,opts.trainingset)));

save(sprintf('./frames/silhouette/video%d/images.mat',opts.video_num),'images');
save(sprintf('./frames/silhouette/video%d/trainingset.mat',opts.video_num),'opts');

