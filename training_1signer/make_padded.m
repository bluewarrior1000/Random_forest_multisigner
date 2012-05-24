%make images with padding
init_options_colourmodel_22_save;
opts.frames_dir         = './frames/tomas/';

w = [31 51 71 91];


I = load(sprintf('%svideo%d/images.mat',opts.frames_dir,opts.video_num));
for i = 1:numel(w)
    opts.windowwidth = w(i);
    opts.padding            = ceil(opts.windowwidth/2);
    images = padarray(I.images,[opts.padding, opts.padding],'symmetric','both');
    save(sprintf('%svideo%d/images%d.mat',opts.frames_dir,opts.video_num,w(i)),'-v7.3','images');
    clear 'images';
end