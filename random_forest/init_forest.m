%options for random forest
init_options;
forest.numtrees     = 10; %number of trees to use in forest
forest.maxdepth     = 3; %maximum depth to grow each tree
forest.numfeatures  = 2; %number of features used for testing
forest.numclasses   = opts.numclasses; %number of classes in decision tree classifiation

%setup an empty forest 
for t = 1:forest.numtrees
    for d = 1:(forest.maxdepth)
        index_d = (1-(1-2^(d-1))):(-(1-2^d));
        index_nextd = (1-(1-2^d)):(-(1-2^(d+1)));
        count = 1;
        for i = index_d
            forest.tree(t).node(i).left = index_nextd(count);
            forest.tree(t).node(i).right = index_nextd(count+1);
            if i<(2^(forest.maxdepth-1))
                forest.tree(t).node(i).leaf = false;
                forest.tree(t).node(i).threshold = 0;
                for f = 1:forest.numfeatures
                    forest.tree(t).node(i).feature(f) = 0;
                end
            else
                forest.tree(t).node(i).leaf = true;
                forest.tree(t).node(i).class = 0;
                forest.tree(t).node(i).distribution = ones(forest.numclasses,1)/forest.numclasses;
            end
            count = count+2;
        end
    end
end
