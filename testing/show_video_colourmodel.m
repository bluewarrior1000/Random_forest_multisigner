%script to get joint locations using trained forests
clear
clc

addpath('../random_forest/')

test_video = [62, 22, 47, 59, 61];
forest_str = {'a','b','c','d'};
dist_thresh = 0:20;

%set fold to show
fold = 2;

opts_load_string = sprintf('init_options_multisigner_fold%d',fold);
eval(opts_load_string);
%colour histogram options
opts.colourhist.bits    = 4;    %number of bits per colour channel
opts.colourhist.smoothvariance = 0.5; %variance used for gaussian when smoothing histograms
opts.colourhist.R = 1e-10;  %regularisation constant added to histograms
opts.colourhist.ref_image_filename  = 'ref.png';
opts.colourhist.ref_seg_filename = 'ref_seg.png';

%load testing frame index
train_idx = load(sprintf('%svideo%d/testingset.mat',opts.frames_dir,test_video(fold)),'opts');
opts.testingset = train_idx.opts.testingset;
opts.testingset = opts.testingset(1):2:opts.testingset(end);

forest = cell(8,1);
countf = 1;
%compile forest of 8 trees
for f_id = 1:4
    temp_F = load(sprintf('%sforest_%d.%d.%d.%d/forest_fold1%s.mat',...
        opts.forest_dir, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
        opts.video_num(4),forest_str{f_id}),'forest','data');
    %append forest
    for f = 1:2
        forest{countf} = temp_F.forest{f};
        countf = countf+1;
    end        
end
opts.video_num = test_video(fold);
j = zeros(2,7);
clr = jet(7);
figure
p = [];
h_img = imagesc(uint8(255*zeros(opts.stdimgheight,opts.stdimgwidth,3))); 
axis image
hold on
for c = 1:(opts.numclasses-1)
    p(c) =  plot(j(1,c),j(2,c),'bo','markerfacecolor',clr(c,:), 'markersize',10);
end
    
lla_h       = plot(j(1,[3,5]),j(2,[3,5]),'r-','linewidth',5);
ula_h       = plot(j(1,[5,7]),j(2,[5,7]),'y-','linewidth',5);
lra_h       = plot(j(1,[2,4]),j(2,[2,4]),'r-','linewidth',5);
ura_h       = plot(j(1,[4,6]),j(2,[4,6]),'y-','linewidth',5);


box = opts.boundingbox;
pred_joints = zeros(2,(opts.numclasses-1),length(opts.testingset));
colour_hist = ref_histogram(opts);
opts.video_filename     = 'x.avs';
video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
opts.seg.slate              = load(sprintf('%sslate_videoNr%d.mat',opts.data_dir,opts.video_num));
opts.seg.slate              = opts.seg.slate.mask;

opts.forest.maxdepth = 32;
for f =1:numel(forest)
    tree = forest{f};
    for t = 1:numel(tree)
        if tree(t).depth >= opts.forest.maxdepth;
            tree(t).leaf = 1;
        end
    end
    forest{f} = tree;
end

for i = 1:length(opts.testingset)
    %load images
    I=mre_avifile(video_path,opts.testingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    Isave = I;
    %add padding
    I = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
    %compute background histogram
    I = uint8(compute_posterior(opts,I,colour_hist)*255);
    dist = zeros(opts.numclasses,box(3)*box(4));
    for f = 1:opts.forest.numtrees
        dist = dist + mxapplytree(opts.numchannels,box(1),box(2),box(3),box(4),forest{f},double(I),opts.numclasses);
    end
    j = get_joints(opts,dist); 
    j(1,:,:) = j(1,:,:) + box(1) - 1;
    j(2,:,:) = j(2,:,:) + box(2) - 1;
    j = j - opts.padding;
    set(h_img,'cdata',Isave);
    for c = 1:(opts.numclasses-1)
        set(p(c),'xdata',j(1,c),'ydata',j(2,c));
    end
    set(lla_h,'xdata',j(1,[3,5]),'ydata',j(2,[3,5]));
    set(ula_h,'xdata',j(1,[5,7]),'ydata',j(2,[5,7]));
    set(lra_h,'xdata',j(1,[2,4]),'ydata',j(2,[2,4]));
    set(ura_h,'xdata',j(1,[4,6]),'ydata',j(2,[4,6]));
    drawnow
    pause(0.02);
    
end


