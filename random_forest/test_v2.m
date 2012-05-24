%test difference between mex apply tree and matlab
box = opts.boundingbox;

figure

%load in video
video_path = sprintf('%s%s',opts.video_dir,opts.video_filename);
vi=mre_avifile(video_path,'info');
data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4) - 1);
data_x = opts.boundingbox(1):(opts.boundingbox(1) + opts.boundingbox(3) - 1);
colour_hist = ref_histogram(opts);
p= [];
setp = true;
clr = jet(7);
save_j = zeros(2,opts.numclasses-1);
count = 1;
for i = opts.testingset
    %compute colour histogram for skin and body from reference image
    I=mre_avifile(video_path,i);
    I=mre_resizebilinear(I,203,360,true);

    %compute background histogram
    img_feat = uint8(compute_posterior(opts,I,colour_hist)*255);
        
    dist = zeros(opts.numclasses,box(3)*box(4));
    for f = 1:opts.forest.numtrees
        dist = dist + mxapplytree(3,box(1),box(2),box(3),box(4),forest{f},double(img_feat),8);
    end
    
    %--------- test smoothing -----------
%     dist = bsxfun(@ldivide,sum(dist),dist);
%     dist = reshape(dist',[box(4),box(3),8]);
%     filt = fspecial('gaussian',10,8);
%     for c = 1:8
%         dist(:,:,c) = imfilter(dist(:,:,c),filt).^10;
%     end
%     dist = reshape(dist,box(4)*box(3),8);
%     dist = dist';
%     %------------------------------------
%     [~, class] = max(dist);
%     subplot(121)
%     imagesc(I(data_y,data_x,:)); axis image
%     subplot(122)    
%     imagesc(reshape(class,box(4),box(3)));

%     imagesc(dist(:,:,3).^10); axis image
%     axis image

    j1 = get_joints(opts,dist);
    j = (save_j+j1)/2;
    if setp == true
        h = imagesc(I(data_y,data_x,:)); axis image
        hold on
        for c = 1:(opts.numclasses-1)
           p(c) =  plot(j(1,c),j(2,c),'bo','markerfacecolor',clr(c,:), 'markersize',15);
           setp = false;
        end
    else
        for c = 1:(opts.numclasses-1)
           set(h,'cdata',I(data_y,data_x,:));
           set(p(c),'xdata',j(1,c),'ydata',j(2,c));
        end
    end
    if mod(count,2)==0
        save_j = j1;
    end
    count = count + 1;
    drawnow
end
 