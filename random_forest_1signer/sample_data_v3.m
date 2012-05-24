%SAMPLE_DATA - creates data for training
%   v2 - uses all points from joint patch and then samples from background
%   the class weights are also calculated
%   v3 - fixed bug where it was possible to sample values outside the
%   bounding box
function points = sample_data_v3(opts, tree_num)
    %fix random seed
    if nargin<2
        tree_num = 0;
    end
    s = RandStream('mt19937ar','Seed',111+tree_num);
    RandStream.setDefaultStream(s);

    %first sample images from training set with replacement
    idx = floor(1+rand(1,opts.numsampleimages)*length(opts.trainingset));
    sample_img_idx = sort(opts.trainingset(idx));
    
    %next sample points from both negative and positive classes, with
    %replacement
    size_data = opts.numsampleimages*opts.numwindows;
    points = struct('x',uint16(zeros(1,size_data)),'y',uint16(zeros(1,size_data)),...
        'class',uint8(zeros(1,size_data)),'img_index',uint32(zeros(1,size_data)));
    count = 1;
    points.class_weight = zeros(1,opts.numclasses);
    for i = 1:opts.numsampleimages
        p=1;
        %for each image use all points from the joint patch, then
        %sample from the background
        for class = 1:(opts.numclasses-1)
%             locs = opts.joint_patch(:,:,class,1+100*(sample_img_idx(i)-1)); %INDEX JUST USED FOR TESTING CODE
            locs = opts.joint_patch(:,:,class,sample_img_idx(i)+1);
            points.x(count:(count+size(locs,1)-1)) = uint32(locs(:,1));
            points.y(count:(count+size(locs,1)-1)) = uint32(locs(:,2));
            points.class(count:(count+size(locs,1)-1)) = uint8(class);
            points.img_index(count:(count+size(locs,1)-1)) = uint32(sample_img_idx(i));
            count=count+size(locs,1);
            p=p+size(locs,1);
            points.class_weight(class) = points.class_weight(class) + size(locs,1);
        end
        class = opts.numclasses;
        for p = p:opts.numwindows
            isbackground = false;
            while ~isbackground;
                x = floor(rand*opts.boundingbox(3)) + opts.boundingbox(1);
                y = floor(rand*opts.boundingbox(4)) + opts.boundingbox(2);
                %extract class of point
%                 locs = opts.joint_patch(:,:,:,1+100*(sample_img_idx(i)-1)); %INDEX JUST USED FOR TESTING CODE
                locs = opts.joint_patch(:,:,:,sample_img_idx(i)+1);
                gt = repmat([x,y],[opts.patchsize,1, opts.numclasses-1]);
                class_test = find(permute(sum(sum(locs==gt,2)==2,1),[3 2 1])>1, 1);
                if isempty(class_test)
                    locs = [x,y];
                    isbackground = true;
                end
            end
            points.x(count) = uint32(locs(1));
            points.y(count) = uint32(locs(2));
            points.class(count) = uint8(class);
            points.img_index(count) = uint32(sample_img_idx(i));
            count = count + 1;
            points.class_weight(class) = points.class_weight(class) + 1;
        end
        if 0; %visualise the samples
            im = imread(sprintf('%sim%05.0f.png',opts.image_dir,sample_img_idx(i)));
            figure(1)
            clf
            imagesc(im); axis image;
            hold on
            plot(points.x(points.img_index(:)==sample_img_idx(i)), points.y(points.img_index(:)==sample_img_idx(i)),'r.')
            pause
        end
    end
    points.class_weight = sum(points.class_weight)./points.class_weight; %class weights used to balance the dataset
end
