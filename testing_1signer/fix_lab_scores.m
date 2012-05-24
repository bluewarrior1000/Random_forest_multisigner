%correct lab scores
for vn = [47 59 61 62]
    for windowwidth = [31 51 71 91]
        opts.video_num          = vn;
        opts.numclasses         = 8;
        opts.windowwidth        = 71;
        opts.forest.maxdepth    = 64;
        opts.forest.numtrees    = 8;
        opts.stdimgwidth        = 360;          %standard width of input images (already scaled)
        opts.stdimgheight       = 203;          %standard height of input images (already scaled)
        opts.padding            = ceil(opts.windowwidth/2);
        opts.boundingbox        = [180+opts.padding,40+opts.padding,opts.stdimgwidth-180,opts.stdimgheight-40];    %bounding box of signer [X, Y, WIDTH, HEIGHT]
        opts.imgwidth           = opts.stdimgwidth + 2*opts.padding;
        opts.imgheight          = opts.stdimgheight + 2*opts.padding;
        opts.windowwidth        = windowwidth;
        opts.data_dir           = '../data/';
        opts.frames_dir         = './frames/lab/';
        opts.results_dir        = sprintf('./results/lab/');

        dist_thresh = 0:20;
        
        %load results
        load(sprintf('%svideo%d/pred_joints_width_%d_depth_%d.mat',opts.results_dir,opts.video_num,opts.windowwidth,opts.forest.maxdepth));
        pred_joints = pred_joints - opts.padding;
        
        %recompute accuracy
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
         %load testing frame index
        train_idx = load(sprintf('%svideo%d/testingset.mat',opts.frames_dir,opts.video_num),'opts');
        opts.testingset = train_idx.opts.testingset;
        id_remove = opts.testingset>size(opts.joints,3);
        opts.testingset(id_remove) = [];
        
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
% 
        save(sprintf('%svideo%d/pred_joints_width_%d_depth_%d.mat',...
           opts.results_dir,opts.video_num,opts.windowwidth, opts.forest.maxdepth),'pred_joints','accuracy','dist_frm_GT');
%         
        
    end
end