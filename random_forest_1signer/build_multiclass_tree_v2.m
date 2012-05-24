%BUILD_MULTICLASS_TREE - builds a multiclass classification tree
%V2 - implements the new vectorised code for sample_node_data, and loops
%over number of test but not images
function tree = build_multiclass_tree_v2(opts,data,images)
    tree_queue = 1;
    delete_index = [];
    tree(1) = struct('left',[],'right',[],'leaf',false,'depth',1,'window_index',1:(opts.numwindows*opts.numsampleimages));
    while ~isempty(tree_queue)
        tree_index = tree_queue(1);
            %check if leaf node
            if ~tree(tree_index).leaf
                if tree(tree_index).depth<=opts.forest.maxdepth
                    %for each type of test calculate the best threshold
                    %value
                    max_info_gain = -inf;
                    bestT = 128;
                    bestfunctype = 1;
                    WI = tree(tree_index).window_index(ones(opts.numsampletests,1),:);
                    for func_type = 1:opts.numfunctypes
                        [feature, offset] = sample_node_data_v5(opts,WI,data,images,func_type);
                        [T, info_gain, index_left, index_right,offset_idx] = ...
                            multiclass_thresh_v3(opts,WI,data,feature);
                        if ~isempty(T) && info_gain>max_info_gain
                            max_info_gain = info_gain;
                            bestT = T;
                            best_offset_idx = offset_idx;
                            bestfunctype = uint8(func_type);
                            best_index_left = index_left;
                            best_index_right = index_right;
                            CDL = hist(data.class(best_index_left),1:opts.numclasses);
                            CDR = hist(data.class(best_index_right),1:opts.numclasses);
                        end
                        
                    end
                    %output info
%                     clc
%                     fprintf('Computing for node: %d\n',tree_index);
                    
                    if ~isempty(T) %not a leaf node
                        tree(tree_index).test = [double(offset(best_offset_idx,:)), double(bestfunctype), double(bestT)];
                        left_index = tree_queue(end) + 1;
                        right_index = tree_queue(end) + 2;
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
                else
                    tree(tree(tree_index).parent).leaf = true;
                    delete_index = [delete_index, tree_index];
                end
            end
        tree_queue(1) = [];
    end
    tree(delete_index) = [];
end