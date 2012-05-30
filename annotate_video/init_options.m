%options for dataset
opts.windowwidth        = 71;
opts.stdimgwidth        = 720;          %standard width of input images (already scaled)
opts.stdimgheight       = 405;          %standard height of input images (already scaled)
opts.padding            = ceil(opts.windowwidth/2);
opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
opts.imgheight          = opts.stdimgheight + 2*opts.padding;
opts.video_filename     = 'x.avs';
opts.video_num          = 47;
opts.video_dir          = '../../Video_database/Signing/Videos/';
opts.data_dir           = '../../Video_database/Signing/Data/';
opts.numchannels        = 3;
opts.numfunctypes       = 4;
opts.numwindows         = 500;              %number of windows to sample per image
opts.numsampletests     = 200;
opts.numsampleimages    = 1000;              %number of images to sample durring training
opts.numclasses         = 8;                %number of different joints + background (background label is assumed to be max label throughout, i.e. if there are 7 joints then background label is 8.
opts.min_pernode        = 2;                %minimum number of samples to allow at a node durring training
opts.scale              = 1; 
opts.patchwidth         = 2;               %radius of patch
opts.valid_frames       = load(sprintf('%svalid_frames_videoNr%d.mat',opts.data_dir,opts.video_num),'valid_frames');
opts.valid_frames       = opts.valid_frames.valid_frames;
opts.trainingset        = opts.valid_frames(300:8:floor(length(opts.valid_frames)*0.6));   %indicies of the images we wish to use as training data 
opts.testingsetstepsize = 16;
opts.testingset         = opts.valid_frames((floor(length(opts.valid_frames)*0.6)+1):opts.testingsetstepsize:end);         %indicies of the images we wish to use as training data  
opts.numclusters        = 160; %number of clusters to cluster pose space when sampling images
%% bootstrap options
opts.bootstrap.percentage = 0.1;            %percentage of false positives to append to training data
opts.bootstrap.num = 1;                     %the number of rounds of bootstrapping when training a forest

%% load body joint coordinates
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

%% options for forest
opts.forest.numtrees     = 4; %number of trees to use in forest
opts.forest.maxdepth     = 64; %maximum depth to grow each tree
% opts.forest.numfeatures  = 2; %number of features used for testing
% opts.forest.numclasses   = opts.numclasses; %number of classes in decision tree classifiation

%% colour histogram options
opts.colourhist.bits    = 4;    %number of bits per colour channel
opts.colourhist.smoothvariance = 1; %variance used for gaussian when smoothing histograms
opts.colourhist.R = 1e-10;  %regularisation constant added to histograms
opts.colourhist.ref_image_filename  = 'ref.png';
opts.colourhist.ref_seg_filename = 'ref_seg.png';

%% segmentation options
opts.seg.Cbins = 1:80;
opts.seg.Qbins = linspace(0,1,80);
opts.seg.Qbins_back = linspace(0,1,80);
opts.seg.numposeclusters = 200;
opts.seg.distthresh = 30;
opts.seg.Pregulariser = 20;
opts.seg.topX = 400;
opts.seg.Pweight = 5;
opts.seg.learningrate = 1.365;

opts.seg.can_width = round([30 25 25 25 25 180]);                                  %width of templates per body part
opts.seg.can_height = round([50 90 90 90 90 200]); 

%% viterbi options
opts.viterbi.windowwidth = 21;  %size of window used for pdf of transitions
opts.viterbi.stepsize = 2;      %steps size used between frames (should be same as step size used in testing set)
if opts.viterbi.stepsize~=opts.testingsetstepsize
    warning('viterbi step size not the same as step size used between frames of testing set')
end