%script to train multiclass joint classifier
%fix random seed
clear
clc
init_options_multisigner_fold5;
if isdeployed == 0
    addpath('../random_forest/')
end

s = RandStream('mt19937ar','Seed',55);
RandStream.setDefaultStream(s);

%load images
images = load_images(opts);

%train forest
tic
[forest, data] = build_forest(opts,images);
toc

%save forest
save(sprintf('%sforest_%d.%d.%d.%d/forest_fold1c.mat',...
    opts.forest_dir, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
    opts.video_num(4)),'forest','data');

