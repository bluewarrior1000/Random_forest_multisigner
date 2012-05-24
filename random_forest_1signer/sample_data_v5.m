%SAMPLE_DATA - creates data for training
%   v2 - uses all points from joint patch and then samples from background
%   the class weights are also calculated
%   v3 - fixed bug where it was possible to sample values outside the
%   bounding box
%   v4 - bug fix for when opts.training set contains a step size
%   v5 - samples a more representative set of training images by clustering
%   images according to pose
function points = sample_data_v5(opts)
    idx = [];

    %cluster poses in trainingset using kmeans, align poses with head
    %position
    joints = opts.joints(:,:,opts.trainingset);
    joints = bsxfun(@minus, joints, joints(:,1,:));
    joints = reshape(joints,14,size(joints,3))';
    %cluster into 5 clusters unless set in the options file
    if isempty(opts.numclusters)
        K = 5;
    else
        K = opts.numclusters;
    end
    
    if K>size(joints,1)
        error('number of clusters is greater than number of training images')
    end
    cluster_idx = kmeans(joints,K);
    if isempty(cluster_idx)
        error('error running kmeans, probably didnt converge')
    else
        fprintf('keans clustering successful!\n');
    end
        
    
    %visualise
    if 0
        %PCA
        [V,D] = eig(cov(joints));
        JJ = bsxfun(@minus,joints,mean(joints));
        d = JJ*V(:,(end-1):1:end);
        clr = lines(K); 
        figure; 
        for c = 1:K; 
            plot(d(cluster_idx==c,1),d(cluster_idx==c,2),'.','color',clr(c,:)); 
            hold on; 
        end
    end
    
    %TODO: after clustering based on pose, apply clustering within each group
    %based on visual content
    idx = zeros(opts.numsampleimages,1);
    num_samp_per_cluster = floor(opts.numsampleimages/K);
    
    if K < opts.numsampleimages
        for c = 1:K
            c_idx = find(cluster_idx==c);
            %sample index
            start_idx = (num_samp_per_cluster*(c-1) + 1);
            end_idx = start_idx + num_samp_per_cluster -1;
            rand_idx = floor(1+rand(1,num_samp_per_cluster)*length(c_idx));
            idx(start_idx:end_idx) = c_idx(rand_idx);
        end
            
        %sample the remaining images from anywhere
        remainder = mod(length(opts.trainingset),K);
        idx((end-remainder+1):end) = floor(1+rand(1,remainder)*length(opts.trainingset));
    else
        %sample the clusters
        cluster_samp = randperm(K);
        cluster_samp = cluster_samp(1:opts.numsampleimages);
        for i = 1:length(cluster_samp)
            c_idx = find(cluster_idx==cluster_samp(i));
            rand_idx = floor(1+rand*length(c_idx));
            idx(i) = c_idx(rand_idx);
        end
    end
        
    %-------- old code --------------------
    %first sample images from training set with replacement
%     idx = floor(1+rand(1,opts.numsampleimages)*length(opts.trainingset));
    %--------------------------------------
    sample_img_idx = sort(opts.trainingset(idx));
    
    %next sample points from both negative and positive classes, with
    %replacement
    size_data = opts.numsampleimages*opts.numwindows;
    points = struct('x',uint16(zeros(1,size_data)),'y',uint16(zeros(1,size_data)),...
        'class',uint8(zeros(1,size_data)),'img_index',uint32(zeros(1,size_data)));
    count = 1;
    points.class_weight = zeros(1,opts.numclasses);
    
    patch = make_patch(opts.patchwidth) + opts.padding;
    for i = 1:opts.numsampleimages
        p=1;
        store_joint = [];
        %for each image use all points from the joint patch, then
        %sample from the background
        for class = 1:(opts.numclasses-1)
            locs = opts.joints(:,class,sample_img_idx(i))';
            locs = locs(ones(size(patch,1),1),:) + patch;
            points.x(count:(count+size(locs,1)-1)) = (locs(:,1));
            points.y(count:(count+size(locs,1)-1)) = (locs(:,2));
            points.class(count:(count+size(locs,1)-1)) = uint8(class);
            points.img_index(count:(count+size(locs,1)-1)) = uint32(find(opts.trainingset==sample_img_idx(i)));
            count=count+size(locs,1);
            p=p+size(locs,1);
            points.class_weight(class) = points.class_weight(class) + size(locs,1);
            store_joint = [store_joint; locs(:,1), locs(:,2)];
        end
        class = opts.numclasses;
        for p = p:opts.numwindows
            isbackground = false;
            while ~isbackground;
                x = floor(rand*opts.boundingbox(3)) + opts.boundingbox(1);
                y = floor(rand*opts.boundingbox(4)) + opts.boundingbox(2);
                %extract class of point
                gt = repmat([x,y],[size(patch,1)*(opts.numclasses-1), 1]);
                if ~any(sum(store_joint == gt,2)==2)
                    locs = [x,y];
                    isbackground = true;
                end
            end
            points.x(count) = (locs(1));
            points.y(count) = (locs(2));
            points.class(count) = uint8(class);
            points.img_index(count) = uint32(find(opts.trainingset==sample_img_idx(i)));
            count = count + 1;
            points.class_weight(class) = points.class_weight(class) + 1;
        end
        if 0; %visualise the samples
            video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
            vi=mre_avifile(video_path,'info');
            I=mre_avifile(video_path,sample_img_idx(i)-1);
            I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
            im = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
            figure(1)
            clf
            imagesc(im); axis image;
            hold on
            ss_idx = find(points.img_index(:)==find(opts.trainingset==sample_img_idx(i)));
            ss_idx(points.class(ss_idx)~=2) = [];
            ssx = points.x(ss_idx);
            ssy = points.y(ss_idx);
            plot(ssx, ssy,'r.')
            pause
        end
    end
    points.class_weight = sum(points.class_weight)./points.class_weight; %class weights used to balance the dataset
    end


        
        
