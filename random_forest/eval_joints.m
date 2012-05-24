%evaluate the predicted joint locations again ground truth
%joint locations are scored correct if they are within a radius of
%'distance' away from the ground truch joint location
function [score,  dist_frm_GT, pred_joints] = eval_joints(opts,distance,pred_joints,forest)
    box = opts.boundingbox;
    %if pred_joints and forest are provided then threshold distance to GT
    %and count correct predictions. If pred_joints is empty then first
    %predict joint locations on groundtruth images. This saves running
    %predictions again for different thresholds. 
    if nargin==4
        pred_joints = zeros(2,(opts.numclasses-1),length(opts.testingset));
        %get predicted joints from video using forest
        video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
        
        colour_hist = ref_histogram(opts);
        for i = 1:length(opts.testingset)
            
            %compute colour histogram for skin and body from reference image
            I=mre_avifile(video_path,opts.testingset(i)-1);
            I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
            
            %add padding
            I =  padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
            
            %compute background histogram
            img_feat = uint8(compute_posterior(opts,I,colour_hist)*255);

            dist = zeros(opts.numclasses,box(3)*box(4));
            for f = 1:opts.forest.numtrees
                dist = dist + mxapplytree(3,box(1),box(2),box(3),box(4),forest{f},double(img_feat),8);
            end
            pred_joints(:,:,i) = get_joints(opts,dist);
        end
        %offset pred_joints back to image coordinates
        pred_joints(1,:,:) = pred_joints(1,:,:) + box(1) - 1;
        pred_joints(2,:,:) = pred_joints(2,:,:) + box(2) - 1;
            
        %translate predicted joints back to unpadded image coordinates
        pred_joints = pred_joints - opts.padding;
    end
    %compute score per training image
    gt_joints = opts.joints(:,:,opts.testingset);
    dist_frm_GT = sqrt(sum((gt_joints - pred_joints).^2,1));
    score = permute(dist_frm_GT<=distance,[3 2 1]);  
end