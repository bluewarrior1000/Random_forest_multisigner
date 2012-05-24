%function to classify an input image using a random forest
function distrib = apply_forest(opts,forest,img_num)
   img = double(mean(imread(sprintf('%sim%04.0f.png',opts.image_dir,opts.testingset(img_num))),3)); 
   label = zeros(size(img));
   data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4));
   data_x = (opts.boundingbox(1):(opts.boundingbox(1)+opts.boundingbox(3)));
   [X,Y] = meshgrid(data_x,data_y);
   data_x = X(:);
   data_y = Y(:);
   distrib = zeros(numel(data_x),opts.numclasses,opts.forest.numtrees);
   
   %classify each pixel according to a weighted vote at leaf nodes
    for f = 1:10%numel(forest)
        tree = forest{f};
        for data_index = 1:length(data_x)
            tree_index = 1;
            while ~tree(tree_index).leaf
                %test at node
                func_type = tree(tree_index).test(5);
                offset = tree(tree_index).test(1:4);
                threshold = tree(tree_index).test(6);
                func = func_pointer_v2(func_type);
                data_xx = data_x(data_index);
                data_yy = data_y(data_index);
                if func_type==1
                   index1 = (data_xx+offset(1)-1)*opts.imgheight + data_yy+offset(2);
                   feature = img(index1);
                else
                   index1 = (data_xx+offset(1)-1)*opts.imgheight + data_yy+offset(2);
                   index2 = (data_xx+offset(3)-1)*opts.imgheight + data_yy+offset(4);
                   feature1 = img(index1);
                   feature2 = img(index2);
                   feature = func(feature1,feature2);
                end
                if feature<threshold
                    tree_index = tree(tree_index).left;
                else
                    tree_index = tree(tree_index).right;
                end
            end
            distrib(data_index,:,f) = tree(tree_index).distribution;
        end
    end
    keyboard
end