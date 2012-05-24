function mcc_wrapper(sarg)
    %set video type here
%     opts.frames_dir         = '/nobackup/scsjc/one_signer/frames/colourmodel_tomas/';
%     opts.forest_dir         = '/nobackup/scsjc/one_signer/forests/colourmodel_tomas/';
%     opts.data_dir           = '/nobackup/scsjc/data/';
    
    opts.frames_dir         = './frames/silhouette/';
    opts.forest_dir         = './forests/silhouette/';
    opts.data_dir           = '../data/';

    if isdeployed == 0
        addpath('../random_forest_1signer/')
    end
    s = str2double(sarg);
    fprintf('Setting s to %02.0f and running...\n',s)
    
    video_num = [22 47 59 61 62];
    tree_str = {'a','b','c','d'};
    
    %get video number and tree number from s
    vn = ceil(s/4);
    tn = s-(vn-1)*4; 
    
    %load some options
    opts.windowwidth        = 71;
    opts.stdimgwidth        = 360;          %standard width of input images (already scaled)
    opts.stdimgheight       = 203;          %standard height of input images (already scaled)
    opts.padding            = ceil(opts.windowwidth/2);
    opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
    opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
    opts.imgheight          = opts.stdimgheight + 2*opts.padding;
    opts.numchannels        = 1;
    opts.numfunctypes       = 4;
    opts.numwindows         = 500;              %number of windows to sample per image
    opts.numsampletests     = 200;
    opts.numsampleimages    = 1000;              %number of images to sample durring training
    opts.numclasses         = 8;                %number of different joints + background (background label is assumed to be max label throughout, i.e. if there are 7 joints then background label is 8.
    opts.min_pernode        = 2;                %minimum number of samples to allow at a node durring training
    opts.scale              = 0.5; 
    opts.patchwidth         = 2;               %radius of patch
    opts.numclusters        = 100; %number of clusters to cluster pose space when sampling images
    %% bootstrap options
    opts.bootstrap.percentage = 0.05;            %percentage of false positives to append to training data
    opts.bootstrap.num = 0;                     %the number of rounds of bootstrapping when training a forest
    
    %set some forest options
    opts.forest.numtrees     = 2; %number of trees to use in forest
    opts.forest.maxdepth     = 128; %maximum depth to grow each tree
    opts.video_num = video_num(vn);
    
    % load body joint coordinates
    load(sprintf('%sfeatMatSmoothed_videoNr%d',opts.data_dir,opts.video_num));
    load(sprintf('%sheadMeanPosMat_videoNr%d',opts.data_dir,opts.video_num));
    load(sprintf('%sshoulderPosMat_videoNr%d',opts.data_dir,opts.video_num));
    load(sprintf('%soffset',opts.data_dir));
    opts.P=[headMeanPosMat(:,[2 1]) ...
    featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
    shoulderPosMat(:,[2 1 4 3])]';
    opts.P=reshape(opts.P,2,[],size(opts.P,2));
    opts.P(1,:,:)=opts.P(1,:,:)*3+offset(1,opts.video_num);
    opts.P(2,:,:)=opts.P(2,:,:)*3+offset(2,opts.video_num);
    opts.P=double(opts.P);
    opts.joints = round((opts.P-1)*opts.scale + 1);

    stream = RandStream('mt19937ar','Seed',s*12);
    RandStream.setDefaultStream(stream);
    
    %load in images
    load(sprintf('%svideo%d/images.mat',opts.frames_dir,opts.video_num));
    
    %pad images
    images = padarray(images,[opts.padding, opts.padding],'symmetric','both');
    
    %load in trainingset
    save_opts = load(sprintf('%svideo%d/trainingset.mat',opts.frames_dir,opts.video_num));
    opts.trainingset = save_opts.opts.trainingset;
    
    %train forest
    [forest, data] = build_forest(opts,images);

    %save forest
    save(sprintf('%svideo%d/forest_%s_width_%d.mat',opts.forest_dir,opts.video_num,tree_str{tn},opts.windowwidth),'forest','data');
    
    exit;
    
    
    