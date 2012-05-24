%SAMPLE_DATA - creates data for training
function points = sample_data(opts, tree_num)
    %fix random seed
    if nargin<2
        tree_num = 0;
    end
    s = RandStream('mt19937ar','Seed',111+tree_num);
    RandStream.setDefaultStream(s);

    %first sample images from training set with replacement
    idx = floor(1+rand(1,opts.numsampleimages)*length(opts.trainingset));
    sample_img_idx = opts.trainingset(idx);
    
    %next sample points from both negative and positive classes, with
    %replacement
    size_data = opts.numsampleimages*opts.numwindows;
    points = struct('x',uint16(zeros(1,size_data)),'y',uint16(zeros(1,size_data)),...
        'class',uint8(zeros(1,size_data)),'img_index',uint32(zeros(1,size_data)));
    count = 1;
    for i = 1:opts.numsampleimages
        for p = 1:opts.numwindows
            %choose which class to sample from
            class = floor(rand*opts.numclasses+1);
            
            if class ~= opts.numclasses %background
                %sample point from class patch of image i;
                idx = floor(rand*opts.patchsize+1);
                locs = opts.joint_patch(idx,:,class,1+100*(sample_img_idx(i)-1)); %INDEX JUST USED FOR TESTING CODE
            else%sample point from the rest of the image i
                isbackground = false;
                while ~isbackground;
                    x = floor(rand*opts.boundingbox(3)+1) + opts.boundingbox(1);
                    y = floor(rand*opts.boundingbox(4)+1) + opts.boundingbox(2);
                    %extract class of point
                    locs = opts.joint_patch(:,:,:,1+400*(sample_img_idx(i)-1)); %INDEX JUST USED FOR TESTING CODE
                    gt = repmat([x,y],[opts.patchsize,1, opts.numclasses-1]);
                    class_test = find(permute(sum(sum(locs==gt,2)==2,1),[3 2 1])>1, 1);
                    if isempty(class_test)
                        locs = [x,y];
                        isbackground = true;
                    end
                end
            end
            points.x(count) = uint32(locs(1));
            points.y(count) = uint32(locs(2));
            points.class(count) = uint8(class);
            points.img_index(count) = uint32(sample_img_idx(i));
            count = count + 1;
        end
        
        if 0; %visualise the samples
            im = imread(sprintf('%sim%04.0f.png',opts.image_dir,sample_img_idx(i)));
            figure(1)
            clf
            imagesc(im); axis image;
            hold on
            plot(points.x(points.img_index(:)==sample_img_idx(i)), points.y(points.img_index(:)==sample_img_idx(i)),'r.')
            pause
        end
            
    end
end