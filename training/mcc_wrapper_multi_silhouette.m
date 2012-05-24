function mcc_wrapper_multi_silhouette(sarg)
    s = str2double(sarg);
    
    fprintf('Setting s to %02.0f and running...\n',s)
    s = s-100;
    tree_str = {'1_2','3_4','5_6','7_8'};
    
    fold = floor((s-1)/4) + 1;
    treenum = mod(s,4);
    treenum(treenum==0) = 4;
    
    runstr = sprintf('train_trees_%s_fold%d',tree_str{treenum},fold);
    eval(runstr);
    exit;
    train_trees_1_2_fold1;
    train_trees_1_2_fold2;
    train_trees_1_2_fold3;
    train_trees_1_2_fold4;
    train_trees_1_2_fold5;
    train_trees_3_4_fold1;
    train_trees_3_4_fold2;
    train_trees_3_4_fold3;
    train_trees_3_4_fold4;
    train_trees_3_4_fold5;
    train_trees_5_6_fold1;
    train_trees_5_6_fold2;
    train_trees_5_6_fold3;
    train_trees_5_6_fold4;
    train_trees_5_6_fold5;
    train_trees_7_8_fold1;
    train_trees_7_8_fold2;
    train_trees_7_8_fold3;
    train_trees_7_8_fold4;
    train_trees_7_8_fold5;
    
    
    