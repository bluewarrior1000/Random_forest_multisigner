%appends to the current data set new samples that have been incorrectly
%classified by the random forest
%v2 - adds samples back in only from the background class only
function data = bootstrap_v2(opts,eval_class,data_input)
    data = data_input;
    %find index of sampled data
    for i = unique(data_input.img_index)
        gt_class = opts.numclasses*ones(opts.boundingbox(4)*opts.boundingbox(3),1);        
        for c = 1:(opts.numclasses-1)
%             locs = opts.joint_patch(:,:,c,1+100*(opts.trainingset(i)-1)); %INDEX JUST USED FOR TESTING CODE
            locs = opts.joint_patch(:,:,c,opts.trainingset(i)+1);
            x = locs(:,1) - opts.boundingbox(1)+1;
            y = locs(:,2) - opts.boundingbox(2)+1;
            index = (x-1).*opts.boundingbox(4) + y;            
            gt_class(index)=c;
        end
        %find incorrect classifications
        img_class = eval_class(((i-1)*opts.boundingbox(3)*opts.boundingbox(4) +1):(i*opts.boundingbox(3)*opts.boundingbox(4)));
        incorrect = find(img_class~=gt_class);
        
        %sample points from incorrect 
        samp_idx = randperm(size(incorrect,1));
        samp_idx = samp_idx(1:round(size(incorrect,1)*opts.bootstrap.percentage));
        samples = incorrect(samp_idx);
        samp_class = gt_class(samp_idx);
        
        %remove samples that lie on joint locations
        samples(samp_class~=opts.numclasses) = [];
        samp_class(samp_class~=opts.numclasses) = [];
        
        [samp_y, samp_x] = ind2sub([opts.boundingbox(4), opts.boundingbox(3)],samples);
        samp_x = samp_x + opts.boundingbox(1) - 1;
        samp_y = samp_y + opts.boundingbox(2) - 1;
        %and add them to the dataset
        data.class_weight = size(data.x,2)./data.class_weight + hist(samp_class,1:opts.numclasses);
        data.class_weight = sum(data.class_weight)./data.class_weight;
        data.x = [data.x, samp_x'];
        data.y = [data.y, samp_y'];
        data.img_index = [data.img_index, i*uint32(ones(1,size(samp_x,1)))];
        data.class = [data.class, samp_class'];   
    end
    [srt, img_idx] = sort(data.img_index);
    data.x = data.x(img_idx);
    data.y = data.y(img_idx);
    data.class = data.class(img_idx);
    data.img_index = srt;
end