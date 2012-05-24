%visualise the window sampling produced by a tree
function vis_samples(opts,forest)
if ~iscell(forest)
    num_trees = 1;
    tree = forest;
    forest = cell(1,1);
    forest{1} = tree;
else
    num_trees = numel(forest);
end
win = cell(1,opts.numfunctypes);
thresh_val = cell(1,opts.numfunctypes);
num_none_leaf = 0;
func_usage_perc = zeros(1,opts.numfunctypes);
for w = 1:opts.numfunctypes
    win{w} = zeros(opts.windowwidth,opts.windowwidth);
end
for f = 1:num_trees;
    tree = forest{f};
    for i = 1:numel(tree)
        if ~tree(i).leaf
            num_none_leaf = num_none_leaf + 1;
            offset = (opts.windowwidth+1)/2;
            y1 = tree(i).test(2)+offset;
            x1 = tree(i).test(1)+offset;
            y2 = tree(i).test(3)+offset;
            x2 = tree(i).test(4)+offset;
            if tree(i).test(5)==1
                win{1}(y1,x1) = win{1}(y1,x1)+1;
                func_usage_perc(1) = func_usage_perc(1)+1;
                thresh_val{1} = [thresh_val{1}, tree(i).test(6)];
            else
                func_usage_perc(tree(i).test(5)) = func_usage_perc(tree(i).test(5))+1;
                win{tree(i).test(5)}(y1,x1) = win{tree(i).test(5)}(y1,x1)+1;
                win{tree(i).test(5)}(y2,x2) = win{tree(i).test(5)}(y2,x2)+1;
                thresh_val{tree(i).test(5)} = [thresh_val{tree(i).test(5)}, tree(i).test(6)];
            end
        end
    end
end
figure
%show sampling distribution
func_usage_perc = 100*func_usage_perc/num_none_leaf;
for func_type = 1:opts.numfunctypes
    subplot(2,2,func_type); imagesc(win{func_type}); colorbar; title(sprintf('Func type: %d, usage: %2.2f%s',func_type, func_usage_perc(func_type),'%'));
end

figure
%show threshold distribution
for func_type = 1:opts.numfunctypes
    subplot(2,2,func_type); hist(thresh_val{func_type},500); title(sprintf('Func type: %d, usage: %2.2f%s',func_type, func_usage_perc(func_type),'%'));
    drawnow
end
