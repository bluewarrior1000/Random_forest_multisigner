addpath('../random_forest_1signer/');
init_options_colourmodel_61_save;
opts.video_num          = 61;
opts.numchannels        = 1;
opts.numclasses         = 8;
opts.windowwidth       = 31;
opts.forest.maxdepth    = 64;
opts.forest.numtrees    = 8;
opts.stdimgwidth        = 360;          %standard width of input images (already scaled)
opts.stdimgheight       = 203;          %standard height of input images (already scaled)
opts.padding            = ceil(opts.windowwidth/2);
opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
opts.imgheight          = opts.stdimgheight + 2*opts.padding;
opts.data_dir           = '../data/';
opts.frames_dir         = './frames/silhouette/';
opts.forest_dir         = '../training_1signer/forests/silhouette/';
opts.results_dir        = './results/silhouette/';

dist_thresh = 0:20;

%load testing images
I = load(sprintf('%svideo%d/images.mat',opts.frames_dir,opts.video_num),'images');
I = padarray(I.images,[opts.padding, opts.padding],'symmetric','both');

%load testing frame index
train_idx = load(sprintf('%svideo%d/testingset.mat',opts.frames_dir,opts.video_num),'opts');
opts.testingset = train_idx.opts.testingset;

forest = cell(1,8);
count = 1;
tree_str = {'a','b','c','d'};

%compile forest
for f = 1:4
    F = load(sprintf('%svideo%d/forest_%s_width_%d.mat',opts.forest_dir,opts.video_num,tree_str{f},opts.windowwidth));
    for c = 1:2
        forest{count} = F.forest{c};
        count = count + 1;
    end
end

%set depth and normalise
for f=1:numel(forest)
    tree = forest{f};
    for t = 1:numel(tree)
        if tree(t).depth >= opts.forest.maxdepth
            tree(t).leaf = 1;
        end
        
        if tree(t).leaf == 1
            tree(t).distribution = tree(t).distribution/sum(tree(t).distribution);
        end
    end
    forest{f} = tree;
end

box = opts.boundingbox;
pred_joints = zeros(2,(opts.numclasses-1),length(opts.testingset));
for i = 1:length(opts.testingset)
    dist = zeros(opts.numclasses,box(3)*box(4));
    for f = 1:opts.forest.numtrees
        dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(I(:,:,i)),opts.numclasses);
    end
    pred_joints(:,:,i) = get_joints(opts,dist);  
    if mod(i,100)==0
        fprintf('frame %d done of %d\n',i,length(opts.testingset));
    end
end
%offset pred_joints back to image coordinates
pred_joints(1,:,:) = pred_joints(1,:,:) + box(1) - 1;
pred_joints(2,:,:) = pred_joints(2,:,:) + box(2) - 1;
pred_joints = pred_joints - opts.padding;

%get GT joint location
addpath('../random_forest_1signer/');
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

%remove from testingset those frames that dont have GT joints
id_remove = opts.testingset>size(opts.joints,3);
opts.testingset(id_remove) = [];
pred_joints(:,:,id_remove) = [];

[score,  dist_frm_GT] = eval_joints(opts,8,pred_joints);
dist_frm_GT = permute(dist_frm_GT,[3 2 1]);

%for each distance threshold from GT location find percentage of
%predicted joints that fall within the bound
accuracy = zeros(length(dist_thresh),opts.numclasses-1);
for t = 1:length(dist_thresh)
    accuracy(t,:) = mean(dist_frm_GT<=dist_thresh(t));
end

save(sprintf('%s/video%d/pred_joints_width_%d_depth_%d.mat',...
   opts.results_dir,opts.video_num,opts.windowwidth, opts.forest.maxdepth),'pred_joints','accuracy','dist_frm_GT');