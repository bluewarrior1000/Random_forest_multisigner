function mcc_wrapper_1signer_test(sarg)

    if isdeployed == 0
        addpath('../random_forest_1signer/')
    end
    s = str2double(sarg);
    jobsetup_labwidths;
    
    
    video_type = {'silhouette','tomas','lab','colourmodel_tomas'};
    video_num = [22 47 59 61 62];
    windowwidth = [31 51 71 91];
    treedepth = [8 16 32 64 128];
    
    vt = video_type{job(s,1)};
    vn = video_num(job(s,2));
    ww = windowwidth(job(s,3));
    td = treedepth(job(s,4));
    
    if strcmp(vt,'silhouette')
        opts.numchannels = 1;
    else
        opts.numchannels = 3;
    end
    
    opts.video_num          = vn;
    opts.numclasses         = 8;
    opts.windowwidth       = ww;
    opts.forest.maxdepth    = td;
    opts.forest.numtrees    = 8;
    opts.stdimgwidth        = 360;          %standard width of input images (already scaled)
    opts.stdimgheight       = 203;          %standard height of input images (already scaled)
    opts.padding            = ceil(opts.windowwidth/2);
    opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
    opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
    opts.imgheight          = opts.stdimgheight + 2*opts.padding;
    
    opts.frames_dir         = sprintf('/nobackup/scsjc/testing/one_signer/frames/%s/',vt);
    opts.forest_dir         = sprintf('/nobackup/scsjc/one_signer/forests/%s/',vt);
    opts.data_dir           = '/nobackup/scsjc/data/';

    opts.results_dir        = sprintf('/nobackup/scsjc/testing/one_signer/results/%s/',vt);

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
        F = load(sprintf('%svideo%d/forest_%s_width_%d.mat',opts.forest_dir,opts.video_num,tree_str{f},opts.windowwidth),'forest');
        for c = 1:2
            forest{count} = F.forest{c};
            count = count + 1;
        end
        clear 'F';
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
    time_done = 0;
    ttt = tic;
    for i = 1:length(opts.testingset)
        
        if strcmp(vt,'silhouette')
            dist = zeros(opts.numclasses,box(3)*box(4));
            for f = 1:opts.forest.numtrees
                dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(I(:,:,i)),opts.numclasses);
            end
        else
            dist = zeros(opts.numclasses,box(3)*box(4));
            for f = 1:opts.forest.numtrees
                dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(I(:,:,:,i)),opts.numclasses);
            end
        end
        pred_joints(:,:,i) = get_joints(opts,dist);  
        
        if mod(i,100) == 0
            time_done = time_done + toc(ttt);
            fprintf('frame %d of %d done, time to completion: %03.2f mins\n',i,length(opts.testingset),(time_done/i)*(length(opts.testingset)-i)/60)
            ttt = tic;
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
    opts.joints = round((opts.P-1)*0.5 + 1);

    %remove from testingset those frames that dont have GT joints
    id_remove = opts.testingset>size(opts.joints,3);
    opts.testingset(id_remove) = [];
    pred_joints(:,:,id_remove) = [];
    
    
    %compute score per training image
    gt_joints = opts.joints(:,:,opts.testingset);
    dist_frm_GT = sqrt(sum((gt_joints - pred_joints).^2,1));
    dist_frm_GT = permute(dist_frm_GT,[3 2 1]);

    %for each distance threshold from GT location find percentage of
    %predicted joints that fall within the bound
    accuracy = zeros(length(dist_thresh),opts.numclasses-1);
    for t = 1:length(dist_thresh)
        accuracy(t,:) = mean(dist_frm_GT<=dist_thresh(t));
    end
    
    save(sprintf('%svideo%d/pred_joints_width_%d_depth_%d.mat',...
       opts.results_dir,opts.video_num,opts.windowwidth, opts.forest.maxdepth),'pred_joints','accuracy','dist_frm_GT');

    exit;