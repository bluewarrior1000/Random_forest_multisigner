%script to make new training scripts
findtxt = 'lab';
replacetxt = '';
tree_txt = {'1_2','3_4','5_6','7_8'};
for fold = 1:5
    for treeid = 1:4
        src = sprintf('train_trees_%s_%s_fold%d.m',tree_txt{treeid},findtxt,fold);
        dest = sprintf('train_trees_%s%s_fold%d.m',tree_txt{treeid},replacetxt,fold);
        disp(src)
        disp(dest)
        copyfile(src,dest)
    end
end
        