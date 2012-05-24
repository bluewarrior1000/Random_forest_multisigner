%visualise negative samples
function vis_neg_samples(opts,data,images)
    distribution = zeros(opts.boundingbox(4),opts.boundingbox(3));
    x = [];
    y = [];
    class = [];
    img_index = [];
    for f = 1:opts.forest.numtrees
        x = [x, data{f}.x - opts.boundingbox(1)+1];
        y = [y, data{f}.y - opts.boundingbox(2)+1];
        class = [class, data{f}.class];
        img_index = [img_index, data{f}.img_index];
    end
    img_index = double(img_index);
    index = (x-1)*opts.boundingbox(4) + y;
    index(class~=opts.numclasses) = [];
    index = sort(index);
    for i = 1:length(index)
        distribution(index(i)) = distribution(index(i)) + 1;
    end
    
    figure
    imagesc(distribution); axis image; colorbar
    
    for i = 1:length(opts.trainingset)
        if sum(img_index==i)>0
            im = images(:,:,:,i);
            distribution = zeros(opts.imgheight,opts.imgwidth);
            x = [];
            y = [];
            class = [];
            for f = 1:opts.forest.numtrees
                idx = data{f}.img_index==i;
                x = [x, data{f}.x(idx)];
                y = [y, data{f}.y(idx)];
                class = [class, data{f}.class(idx)];
            end
            x = double(x);
            y = double(y);
            index = ((x-1)*opts.imgheight + y);
            index(class~=opts.numclasses) = [];
            index = sort(index);
            for j = 1:length(index)
                distribution(index(j)) = distribution(index(j)) + 1;
            end
            figure(2)
            clf
            im_dist = ind2rgb(distribution,bone(max(distribution(:))));
            mask = distribution~=0;
            imagesc(im); axis image;
            hold on
            h = imagesc(im_dist);
            set(h,'alphadata',mask*0.9); 
            title(sprintf('Image number %d',opts.trainingset(i)));
            pause
        end
    end
end