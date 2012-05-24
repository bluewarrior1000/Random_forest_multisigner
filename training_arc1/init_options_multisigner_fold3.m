%options for dataset
opts.windowwidth        = 91;
opts.stdimgwidth        = 360;          %standard width of input images (already scaled)
opts.stdimgheight       = 203;          %standard height of input images (already scaled)
opts.padding            = ceil(opts.windowwidth/2);
opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
opts.imgheight          = opts.stdimgheight + 2*opts.padding;
opts.video_num          = [59,61,62,22];
opts.data_dir           = '/nobackup/scsjc/data/';
opts.frames_dir         = '/nobackup/scsjc/frames/tomas/';
opts.forest_dir         = '/nobackup/scsjc/forests/tomas/';
opts.numchannels        = 3;
opts.numfunctypes       = 4;
opts.numwindows         = 500;              %number of windows to sample per image
opts.numsampletests     = 200;
opts.numimagespersigner = 500;
opts.numsampleimages    = length(opts.video_num)*opts.numimagespersigner;  %number of images to sample durring training
opts.numclasses         = 8;                %number of different joints + background (background label is assumed to be max label throughout, i.e. if there are 7 joints then background label is 8.
opts.min_pernode        = 2;                %minimum number of samples to allow at a node durring training
opts.scale              = 0.5; 
opts.patchwidth         = 2;               %radius of patch
opts.numclusters        = 100; %number of clusters to cluster pose space when sampling images
%% bootstrap options
opts.bootstrap.percentage = 0.05;            %percentage of false positives to append to training data
opts.bootstrap.num = 0;                     %the number of rounds of bootstrapping when training a forest

%% options for forest
opts.forest.numtrees     = 2; %number of trees to use in forest
opts.forest.maxdepth     = 128; %maximum depth to grow each tree
