%BUILD_MULTICLASS_TREE - builds a multiclass classification tree
function tree = build_multiclass_tree(opts)
    global feature;
    global data;
    tree_queue = 1;
    delete_index = [];
    tree(1) = struct('left',[],'right',[],'leaf',false,'depth',1,'window_index',1:(opts.numwindows*opts.numsampleimages));
    while ~isempty(tree_queue)
        profile on
        tree_index = tree_queue(1);
            %check if leaf node
            if ~tree(tree_index).leaf
                if tree(tree_index).depth<=opts.forest.maxdepth
                    %for each type of test calculate the best threshold value
                    info_gain = 0;
                    max_info_gain = -inf;
                    bestT = 128;
                    bestfunctype = 1;
                    for feat_num = 1:opts.numsampletests
                        feature = sample_node_data_v4(opts,tree(tree_index).window_index);
                        [T,info_gain, index_left, index_right] = ...
                            multiclass_thresh_v2(opts, tree(tree_index).window_index);
                        if info_gain>max_info_gain
                            feature.feature_val = [];
                            max_info_gain = info_gain;
                            bestT = T;
                            bestfeature = feature;
                            best_index_left = index_left;
                            best_index_right = index_right;
                            CDL = hist(data.class(best_index_left),1:opts.numclasses);
                            CDR = hist(data.class(best_index_right),1:opts.numclasses);
                        end
%                         fprintf('node: %d, testing feature: %d, func type: %d\n',tree_index,feat_num,feature.func_type);
                    end
                    
                    if T~=-1 %not a leaf node
                        tree(tree_index).feature = bestfeature;
                        left_index = tree_queue(end) + 1;
                        right_index = tree_queue(end) + 2;
                        tree(tree_index).threshold = bestT;
                        tree(tree_index).left = left_index;
                        tree(tree_index).right = right_index;
                        tree(left_index).depth = tree(tree_index).depth+1;
                        tree(right_index).depth = tree(tree_index).depth+1;
                        tree(left_index).parent = tree_index;
                        tree(right_index).parent = tree_index;
                        tree(left_index).window_index = best_index_left;
                        tree(right_index).window_index = best_index_right;
                        tree(left_index).leaf = false;
                        tree(right_index).leaf = false;
                        tree(left_index).distribution = CDL;
                        tree(right_index).distribution = CDR;
                        tree_queue = [tree_queue, tree_queue(end)+1, tree_queue(end)+2];
                    else
                        tree(tree_index).leaf = true;
                    end
                    
                    if tree_index ==1; profile off; profile viewer; end
                    keyboard
                else
                    tree(tree(tree_index).parent).leaf = true;
                    delete_index = [delete_index, tree_index];
                end
            end
        tree_queue(1) = [];
    end
    tree(delete_index) = [];
end