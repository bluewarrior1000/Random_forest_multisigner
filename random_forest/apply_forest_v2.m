%function to classify an input image using a random forest
%v2 - faster than v1, vectorised
function idxp = apply_forest_v2(opts,forest,image_set, visualise)
   data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4) - 1);
   data_x = opts.boundingbox(1):(opts.boundingbox(1) + opts.boundingbox(3) - 1);
   [X,Y] = meshgrid(data_x,data_y);
   data_x = repmat(X(:),size(image_set,4),1);
   data_y = repmat(Y(:),size(image_set,4),1);
   data_img_index = repmat(1:size(image_set,4),size(X(:),1),1);
   data_img_index = data_img_index(:);
   distrib = zeros(numel(data_x),opts.numclasses,numel(forest));
   
   %classify each pixel according to a weighted vote at leaf nodes
    for f = 1:numel(forest)
        tree = forest{f};
        pixel_index = [];
        pixel_index{1} = 1:length(data_x);
        tree_queue = 1;
        while ~isempty(tree_queue)
            tree_index = tree_queue(1);
            if tree(tree_index).leaf || tree(tree_index).depth==opts.forest.maxdepth;
                if tree_index==1
                    tree_queue(1) = [];
                    continue
                end
                if ~isempty(pixel_index{tree_index})
                    distrib(pixel_index{tree_index},:,f) = tree(tree_index).distribution(ones(length(pixel_index{tree_index}),1),:);
                end
            else
                %test at node
                channel = tree(tree_index).test(7);
                func_type = tree(tree_index).test(5);
                offset = tree(tree_index).test(1:4);
                threshold = tree(tree_index).test(6);
                func = func_pointer_v2(func_type);
                data_xx = data_x(pixel_index{tree_index});
                data_yy = data_y(pixel_index{tree_index});
                img_index = data_img_index(pixel_index{tree_index});
                if func_type==1
                   index1 = (double(opts.imgwidth*opts.imgheight))*((img_index-1)*opts.numchannels + (channel-1)) + double((data_xx+offset(1)-1)*double(opts.imgheight) + data_yy+offset(2));
                   feature = double(image_set(index1));
                else
                   index1 = (double(opts.imgwidth*opts.imgheight))*((img_index-1)*opts.numchannels + (channel-1)) + double((data_xx+offset(1)-1)*double(opts.imgheight) + data_yy+offset(2));
                   index2 = (double(opts.imgwidth*opts.imgheight))*((img_index-1)*opts.numchannels + (channel-1)) + double((data_xx+offset(3)-1)*double(opts.imgheight) + data_yy+offset(4));
                   feature1 = double(image_set(index1));
                   feature2 = double(image_set(index2));
                   feature = func(feature1,feature2);
                end
                pixel_index{tree_queue(end)+1} = pixel_index{tree_index}(feature<=threshold);
                pixel_index{tree_queue(end)+2} = pixel_index{tree_index}(feature>threshold);
                tree_queue = [tree_queue, tree_queue(end)+1, tree_queue(end)+2];
            end
            tree_queue(1) = [];
        end   
    end

    distrib = distrib./repmat(sum(distrib,2),[1,opts.numclasses,1]);
    distrib(:,8,:) = distrib(:,8,:);
    
    ll = sum(distrib,3)/opts.numclasses;
    [sdf idxp] = max(ll,[],2);
%     [sdf idxp] = max(distrib,[],2);
%     idxp = permute(idxp,[1,3,2]);
%     idxp = idxp';
%     hh = hist(idxp,1:8);
%     [sdf, idxp] = max(hh);
    if visualise == true
        figure
        im = reshape(idxp,opts.boundingbox(4),opts.boundingbox(3),size(image_set,4));
        for i = 1:size(image_set,4)
%             subplot(121)
%             img = imread(sprintf('%sim%05.0f.png',opts.image_dir,opts.testingset(i)));
%             data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4) - 1);
%             data_x = opts.boundingbox(1):(opts.boundingbox(1) + opts.boundingbox(3) - 1);
%             box_img = img(data_y,data_x,:);
%             imagesc(uint8(box_img)); axis image;
%             subplot(122)
%             imagesc(uint8(box_img)); axis image;
%             hold on
%             
%             alpha = im(:,:,i)~=8;
%             color_im = ind2rgb(im(:,:,i),jet(8));
%             im_handle = imagesc(color_im); 
%             set(im_handle,'alphadata',alpha*0.8);
%             title(['frame: ' num2str(i)]);
            
            subplot(3,3,1)
             img = image_set(:,:,:,i);
            data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4) - 1);
            data_x = opts.boundingbox(1):(opts.boundingbox(1) + opts.boundingbox(3) - 1);
            box_img = img(data_y,data_x,:);
            imagesc(uint8(box_img)); axis image;
            t = {'head','right wrist','left wrist','right elbow','left elbow','right shldr','left shldr'};
            for j = 1:opts.numclasses
                subplot(3,3,j+1)
                dist = double(reshape(ll(:,j),opts.boundingbox(4),opts.boundingbox(3),size(image_set,4)));
                imagesc(dist(:,:,i)); axis image; 
                if j<8
                    title(t{j})
                else
                    title('background')
                end
            end
            drawnow
            pause;
        end
    end
end