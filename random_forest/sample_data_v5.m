%SAMPLE_DATA - creates data for training
%   v2 - uses all points from joint patch and then samples from background
%   the class weights are also calculated
%   v3 - fixed bug where it was possible to sample values outside the
%   bounding box
%   v4 - bug fix for when opts.training set contains a step size
%   v5 - samples a more representative set of training images by clustering
%   images according to pose
function points = sample_data_v5(opts)
    %cluster poses in trainingset using kmeans, align poses with head
    %position
    
    %for each video load joints, cluster and sample
    count = 1;
    vidmaxidx = 0;
    size_data = opts.numimagespersigner*opts.numwindows*length(opts.video_num);
    points = struct('x',uint16(zeros(1,size_data)),'y',uint16(zeros(1,size_data)),...
        'class',uint8(zeros(1,size_data)),'img_index',uint32(zeros(1,size_data)));

    points.class_weight = zeros(1,opts.numclasses);
        
    for v_num = 1:length(opts.video_num)
        % load body joint coordinates
        load(sprintf('%sfeatMatSmoothed_videoNr%d',opts.data_dir,opts.video_num(v_num)));
        load(sprintf('%sheadMeanPosMat_videoNr%d',opts.data_dir,opts.video_num(v_num)));
        load(sprintf('%sshoulderPosMat_videoNr%d',opts.data_dir,opts.video_num(v_num)));
        load(sprintf('%soffset',opts.data_dir));
        opts.P=[headMeanPosMat(:,[2 1]) ...
        featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
        shoulderPosMat(:,[2 1 4 3])]';
        opts.P=reshape(opts.P,2,[],size(opts.P,2));
        opts.P(1,:,:)=opts.P(1,:,:)*3+offset(1,opts.video_num(v_num));
        opts.P(2,:,:)=opts.P(2,:,:)*3+offset(2,opts.video_num(v_num));
        opts.P=double(opts.P);
        opts.joints = round((opts.P-1)*opts.scale + 1);
        
        video_opts = load(sprintf('%svideo%d/trainingset.mat',opts.frames_dir ,opts.video_num(v_num)),'opts');
        opts.trainingset = video_opts.opts.trainingset;
        
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
        cluster_idx = kmeans(joints,K,'emptyaction','singleton');
        
        idx = zeros(opts.numimagespersigner,1);
        num_samp_per_cluster = floor(opts.numimagespersigner/K);

        if K < opts.numimagespersigner
            for c = 1:K
                c_idx = find(cluster_idx==c);
                %sample index
                start_idx = (num_samp_per_cluster*(c-1) + 1);
                end_idx = start_idx + num_samp_per_cluster -1;
                rand_idx = floor(1+rand(1,num_samp_per_cluster)*length(c_idx));
                idx(start_idx:end_idx) = c_idx(rand_idx);
            end

            %sample the remaining images from anywhere
            remainder = opts.numimagespersigner - num_samp_per_cluster*opts.numclusters;
            if remainder ~= 0 
                idx((end-remainder+1):end) = floor(1+rand(1,remainder)*length(opts.trainingset));
            end
        else
            %sample the clusters
            cluster_samp = randperm(K);
            cluster_samp = cluster_samp(1:opts.numimagespersigner);
            for i = 1:length(cluster_samp)
                c_idx = find(cluster_idx==cluster_samp(i));
                rand_idx = floor(1+rand*length(c_idx));
                idx(i) = c_idx(rand_idx);
            end
        end
        sample_img_idx = sort(idx);
        %next sample points from both negative and positive classes, with
        %replacement
        patch = make_patch(opts.patchwidth) + opts.padding;
        joints = opts.joints(:,:,opts.trainingset);
        for i = 1:opts.numimagespersigner
            p=1;
            store_joint = [];
            %for each image use all points from the joint patch, then
            %sample from the background
            for class = 1:(opts.numclasses-1)
                locs = joints(:,class,sample_img_idx(i))';
                locs = locs(ones(size(patch,1),1),:) + patch;
                points.x(count:(count+size(locs,1)-1)) = (locs(:,1));
                points.y(count:(count+size(locs,1)-1)) = (locs(:,2));
                points.class(count:(count+size(locs,1)-1)) = uint8(class);
                points.img_index(count:(count+size(locs,1)-1)) = uint32(vidmaxidx + sample_img_idx(i));
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
                points.img_index(count) = uint32(vidmaxidx + sample_img_idx(i));
                count = count + 1;
                points.class_weight(class) = points.class_weight(class) + 1;
            end
        end    
        vidmaxidx = vidmaxidx + length(opts.trainingset);
    end
    points.class_weight = sum(points.class_weight)./points.class_weight; %class weights used to balance the dataset
end


        
        
