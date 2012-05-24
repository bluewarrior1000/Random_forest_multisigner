%appends to the current data set new samples that have been incorrectly
%classified by the random forest
function data = bootstrap(opts,eval_class,data_input,i)
    %offset joint patches due to padding
    data = data_input;
    gt_class = opts.numclasses*ones(opts.boundingbox(4)*opts.boundingbox(3),1);        
    patch = make_patch(opts.patchwidth) + opts.padding;
    for c = 1:(opts.numclasses-1)
        locs = opts.joints(:,c,opts.trainingset(i))';
        locs = locs(ones(size(patch,1),1),:) + patch;
        x = locs(:,1) - opts.boundingbox(1)+1;
        y = locs(:,2) - opts.boundingbox(2)+1;
        index = (x-1).*opts.boundingbox(4) + y;            
        gt_class(index)=c;
    end
    %find incorrect classifications
    incorrect = find(eval_class(:)~=gt_class);

    %sample points from incorrect 
    samp_idx = randperm(size(incorrect,1));
    samp_idx = samp_idx(1:round(size(incorrect,1)*opts.bootstrap.percentage));
    samples = incorrect(samp_idx);
    samp_class = gt_class(samp_idx);
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