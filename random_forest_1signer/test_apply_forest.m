function distribution = test_apply_forest(opts,forest,img)
    img = double(img);
    tree = forest{1};
    maxn = opts.boundingbox(3)*opts.boundingbox(4);
    distribution = zeros(8,maxn);
    test_im = zeros(opts.boundingbox(4),opts.boundingbox(3));
    i = 1:maxn;
    data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4) - 1);
    data_x = opts.boundingbox(1):(opts.boundingbox(1) + opts.boundingbox(3) - 1);
    [X,Y] = meshgrid(data_x,data_y);
    data_x = X(:);
    data_y = Y(:);
    ii = sub2ind([opts.imgheight,opts.imgwidth],data_y,data_x);
    ii = sort(ii);

    for i = 1:maxn
        j = 1;
        while ~tree(j).leaf
            switch tree(j).test(5)
                case 1
                    feature = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth) + ii(i) + tree(j).test(1)*opts.imgheight + tree(j).test(2));
                case 2
                    feature1 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(1)*opts.imgheight + tree(j).test(2));
                    feature2 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(3)*opts.imgheight + tree(j).test(4));
                    feature = feature1 - feature2;
                case 3
                    feature1 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(1)*opts.imgheight + tree(j).test(2));
                    feature2 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(3)*opts.imgheight + tree(j).test(4));
                    feature = abs(feature1 - feature2);
                case 4
                    feature1 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(1)*opts.imgheight + tree(j).test(2));
                    feature2 = img(((tree(j).test(7)-1)*opts.imgheight*opts.imgwidth)  + ii(i) + tree(j).test(3)*opts.imgheight + tree(j).test(4));
                    feature = feature1 + feature2;
            end              
            if feature <= tree(j).test(6)
                j = tree(j).left;
            else
                j = tree(j).right;
            end
        end
        distribution(:,i) = tree(j).distribution/sum(tree(j).distribution);
        test_im(i) = img(ii(i));
    end
end
