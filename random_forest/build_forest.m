%function build a multiclass random forest
function [forest, data] = build_forest(opts, images)
    forest = cell(opts.forest.numtrees,1);
    box = opts.boundingbox;

    %setup data
    for f = 1:numel(forest)
        data{f} = sample_data_v5(opts);
    end
    
    %train forest
    parfor f = 1:numel(forest)
        forest{f} = build_multiclass_tree_v5(opts,data{f},images);
        fprintf('forest %d\n',f);
    end
        
    %train with bootstrapping
    for b = 1:opts.bootstrap.num    
        %for each traing image bootstrap false positives
        for f = 1:numel(forest)
            for i = unique(data{f}.img_index)
                dist = zeros(8,box(3)*box(4));
                for ff = 1:opts.forest.numtrees
                    dist = dist + mxapplytree(3,box(1),box(2),box(3),box(4),forest{f},double(images(:,:,:,i)),8);
                end
                [~, class] = max(dist);
                class = reshape(class,box(4),box(3));
                data{f} = bootstrap(opts,class,data{f},i);
            end
            %sort the data according to image index
            [srt, img_idx] = sort(data{f}.img_index);
            data{f}.x = data{f}.x(img_idx);
            data{f}.y = data{f}.y(img_idx);
            data{f}.class = data{f}.class(img_idx);
            data{f}.img_index = srt;
        end
        fprintf('begun retraining on bootstrapped data\n');

        %retrain tree
        parfor f = 1:numel(forest)
            forest{f} = build_multiclass_tree_v5(opts,data{f},images);
            fprintf('forest %d\n',f);
        end
        fprintf('bootstrap %d complete, data size: %f\n',b,length(data{1}.x));
    end
end