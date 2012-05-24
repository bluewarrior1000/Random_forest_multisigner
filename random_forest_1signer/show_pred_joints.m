%visualise the predicted joints on testing data
function show_pred_joints(opts,forest,showGT,pred_joints)
   
    use_provided_joints = false;
    
    if nargin==4
        use_provided_joints = true;
    end
    
    figure
    box = opts.boundingbox;
    %load in video
    video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
    vi=mre_avifile(video_path,'info');
    box2 = opts.boundingbox;
    box2(1:2)= box(1:2)-opts.padding;
    data_y = box2(2):(box2(2) + box2(4) - 1);
    data_x = box2(1):(box2(1) + box2(3) - 1);
    colour_hist = ref_histogram(opts);
    p = [];
    gt.joint_handle = [];
    gt.line_handle = [];

    %set joint marker colours
    if showGT == true
        clr = ones(opts.numclasses-1,3);
        joints = opts.joints;
        joints(1,:,:) = joints(1,:,:) - box2(1) + 1;
        joints(2,:,:) = joints(2,:,:) - box2(2) + 1;
        joints = permute(joints,[2 1 3]);
    else
        clr = jet(7);
    end
    
    plot_title = {'predicted joints', 'colour posterior', 'head','right wrist','left wrist','right elbow','left elbow','right shldr','left shldr'};
    
    for i = 1:length(opts.testingset)
        %compute colour histogram for skin and body from reference image
        I=mre_avifile(video_path,opts.testingset(i)-1);
        I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
        

        %compute background histogram
        img_feat = uint8(compute_posterior(opts,I,colour_hist)*255);
        img_feat_padded = padarray(img_feat,[opts.padding, opts.padding, 0],'symmetric','both');

        dist = zeros(opts.numclasses,box(3)*box(4));
        for f = 1:opts.forest.numtrees
            dist = dist + mxapplytree(3,box(1),box(2),box(3),box(4),forest{f},double(img_feat_padded),8);
        end
        if ~use_provided_joints
            [j, dist] = get_joints(opts,dist);                
        else
            j = pred_joints(:,:,i);
            j(1,:) = j(1,:) - box(1) + 1;
            j(2,:) = j(2,:) - box(2) + 1;
            j = j + opts.padding;
            dist = reshape(permute(dist,[2 1]),[box(4),box(3),opts.numclasses]);
        end
        if i == 1
            subplot(331)
            h_img = imagesc(I(data_y,data_x,:)); axis image
            hold on
            %draw skelton
%           shoulder_h  = plot(j(1,[6,7]),j(2,[6,7]),'b-','linewidth',5);
            lla_h       = plot(j(1,[3,5]),j(2,[3,5]),'r-','linewidth',5);
            ula_h       = plot(j(1,[5,7]),j(2,[5,7]),'y-','linewidth',5);
            lra_h       = plot(j(1,[2,4]),j(2,[2,4]),'r-','linewidth',5);
            ura_h       = plot(j(1,[4,6]),j(2,[4,6]),'y-','linewidth',5);
            
            for c = 1:(opts.numclasses-1)
                p(c) =  plot(j(1,c),j(2,c),'bo','markerfacecolor',clr(c,:), 'markersize',10);
                %display ground truth joints
                if showGT == true
                    gt(c).joint_handle = plot(joints(c,1,opts.testingset(i)), joints(c,2,opts.testingset(i)),'bo','markerfacecolor','y');
                    gt(c).line_handle = line([joints(c,1,opts.testingset(i)) j(1,c)] , [joints(c,2,opts.testingset(i)) j(2,c)],'color','w','linewidth',1);
                end
            end
             
            title(plot_title{1})
            
            subplot(332)
            h_conf = imagesc(img_feat(data_y,data_x,:)); axis image
            title(plot_title{2})
            h_pred = [];
            for c = 3:(opts.numclasses+1)
                subplot(3,3,c)
                h_pred(c-2) = imagesc(dist(:,:,c-2)); axis image
                title(plot_title{c})
            end 
        else
            set(h_img,'cdata',I(data_y,data_x,:));
            for c = 1:(opts.numclasses-1)
               set(p(c),'xdata',j(1,c),'ydata',j(2,c));
               %display ground truth joints
                if showGT == true
                    set(gt(c).joint_handle,'xdata',joints(c,1,opts.testingset(i)),'ydata', joints(c,2,opts.testingset(i)));
                    set(gt(c).line_handle,'xdata',[joints(c,1,opts.testingset(i)) j(1,c)],'ydata', [joints(c,2,opts.testingset(i)) j(2,c)]);
                end
            end
            
            %draw skeleton
%             set(shoulder_h,'xdata',j(1,[6,7]),'ydata',j(2,[6,7]));
            set(lla_h,'xdata',j(1,[3,5]),'ydata',j(2,[3,5]));
            set(ula_h,'xdata',j(1,[5,7]),'ydata',j(2,[5,7]));
            set(lra_h,'xdata',j(1,[2,4]),'ydata',j(2,[2,4]));
            set(ura_h,'xdata',j(1,[4,6]),'ydata',j(2,[4,6]));
            
            set(h_conf,'cdata',img_feat(data_y,data_x,:));
            
            for c = 3:(opts.numclasses+1)
                set(h_pred(c-2),'cdata',dist(:,:,c-2));
            end
            
            %display ground truth joints
            if showGT == true
            end
        end
        pause(0.04)
        drawnow
    end
end