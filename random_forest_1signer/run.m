%script to train random forest classifier
clear
clc
init_options;
images = load_images(opts,opts.trainingset);
%train
tic
[forest, data] = build_forest(opts,images);
toc
% images = load_images(opts,20001:20200);
% d = apply_forest_v2(opts,forest,images.frames,true);
