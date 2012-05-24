%options for dataset
opts.windowwidth        = 51;
opts.video_filename     = 'x.avs';
opts.trans_dir          = '..\Image_database\Signing\';
opts.video_dir          = '..\Video_database\Signing\video22\';
opts.joint_dir          = '..\Video_database\Signing\video22\Groundtruth\';
opts.numchannels        = 3;
opts.numfunctypes       = 4;
opts.numwindows         = 500;                %number of windows to sample per image
opts.numsampletests     = 200;
opts.numsampleimages    = 1000;                   %number of images to sample durring training
opts.numclasses         = 8;                    %number of different joints + background (background label is assumed to be max label throughout, i.e. if there are 7 joints then background label is 8.
opts.min_pernode        = 2;                    %minimum number of samples to allow at a node durring training
opts.trainingset        = 1:20:30000;                %indicies of the images we wish to use as training data  
opts.scale              = 0.5;
opts.testingset         = 30000:2:43000;              %indicies of the images we wish to use as training data  
opts.patchsize          = 13;                   %number of pixels for each joint patch
opts.imgwidth           = 360;          %standard width of input images (already scaled)
opts.imgheight          = 203;          %standard height of input images (already scaled)
pad = ceil(opts.windowwidth/2);
opts.boundingbox        = [170+pad,pad,opts.imgwidth-170-2*pad,opts.imgheight-2*pad];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
%% bootstrap options
opts.bootstrap.percentage = 0.1;            %percentage of false positives to append to training data
opts.bootstrap.num = 1;                    %the number of rounds of bootstrapping when training a forest
%% load ground truth patches
jcoords = load(sprintf('%sjoint_patch.mat',opts.joint_dir));
opts.joint_patch = round(jcoords.joint_patch);
clear('jcoords');

%% load body joint coordinates
jcoords = load(sprintf('%slabels.mat',opts.joint_dir));
opts.joints = jcoords.joints*opts.scale;

% +-----------------------------------------
% | BODYPART |  1  |  2  |  3  |  4  |  5  |
% | NAME     | hed | ura | lra | ula | lla | 
% +-----------------------------------------
%form lookup table for bodyparts
opts.table_part = [  1 2;
                    5 7;
                    3 5;
                    6 8;
                    4 6];
clear('jcoords');

%% options for forest
opts.forest.numtrees     = 4; %number of trees to use in forest
opts.forest.maxdepth     = 100; %maximum depth to grow each tree
% opts.forest.numfeatures  = 2; %number of features used for testing
% opts.forest.numclasses   = opts.numclasses; %number of classes in decision tree classifiation

%% colour histogram options
opts.colourhist.bits    = 4;    %number of bits per colour channel
opts.colourhist.smoothvariance = 1; %variance used for gaussian when smoothing histograms
opts.colourhist.R = 1e-10;  %regularisation constant added to histograms
opts.colourhist.ref_image_filename  = 'ref.png';
opts.colourhist.ref_seg_filename = 'ref_seg.png';

