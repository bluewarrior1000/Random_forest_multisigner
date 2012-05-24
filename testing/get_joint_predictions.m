%script to get joint locations using trained forests
if isdeployment==0
    addpath('../random_forest/')
end

test_video = [62, 22, 47, 59, 61];
forest_str = {'a','b','c','d'};
dist_thresh = 0:20;

for fold = 1:5
    opts_load_string = sprintf('init_options_multisigner_fold%d',fold);
    eval(opts_load_string);
    opts.forest.maxdepth = 32;
    %load testing images
    I = load(sprintf('%svideo%d/images.mat',opts.frames_dir,test_video(fold)),'images');
    I = I.images;
    
    %load testing frame index
    train_idx = load(sprintf('%svideo%d/testingset.mat',opts.frames_dir,test_video(fold)),'opts');
    opts.testingset = train_idx.opts.testingset;
    
    forest = cell(8,1);
    countf = 1;
    %compile forest of 8 trees
    for f_id = 1:4
        temp_F = load(sprintf('%sforest_%d.%d.%d.%d/forest_fold1%s.mat',...
            opts.forest_dir, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
            opts.video_num(4),forest_str{f_id}),'forest','data');
        %append forest
        for f = 1:2
            forest{countf} = temp_F.forest{f};
            countf = countf+1;
        end        
    end
    
    for f = 1:numel(forest)
        tree= forest{f};
        for t = 1:numel(tree)
            if tree(t).depth>=opts.forest.maxdepth
                tree(t).leaf = 1;
            end
        end
        forest{f} = tree;
    end
    
    box = opts.boundingbox;
    pred_joints = zeros(2,(opts.numclasses-1),length(opts.testingset));
    for i = 1:length(opts.testingset)
        dist = zeros(opts.numclasses,box(3)*box(4));
        for f = 1:opts.forest.numtrees
            dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(I(:,:,:,i)),opts.numclasses);
        end
        pred_joints(:,:,i) = get_joints(opts,dist);  
    end
    %offset pred_joints back to image coordinates
    pred_joints(1,:,:) = pred_joints(1,:,:) + box(1) - 1;
    pred_joints(2,:,:) = pred_joints(2,:,:) + box(2) - 1;
    pred_joints = pred_joints - opts.padding;

    %get GT joint location
    load(sprintf('%sfeatMatSmoothed_videoNr%d',opts.data_dir,test_video(fold)));
    load(sprintf('%sheadMeanPosMat_videoNr%d',opts.data_dir,test_video(fold)));
    load(sprintf('%sshoulderPosMat_videoNr%d',opts.data_dir,test_video(fold)));
    load(sprintf('%soffset',opts.data_dir));
    opts.P=[headMeanPosMat(:,[2 1]) ...
    featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
    shoulderPosMat(:,[2 1 4 3])]';
    opts.P=reshape(opts.P,2,[],size(opts.P,2));
    opts.P(1,:,:)=opts.P(1,:,:)*3+offset(1,test_video(fold));
    opts.P(2,:,:)=opts.P(2,:,:)*3+offset(2,test_video(fold));
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
    
    save(sprintf('%sforest_%d.%d.%d.%d/pred_joints_depth_%d.mat',...
        opts.results_dir, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
        opts.video_num(4),opts.forest.maxdepth),'pred_joints','accuracy','dist_frm_GT');
end

