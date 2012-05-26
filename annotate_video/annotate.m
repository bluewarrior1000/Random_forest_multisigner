%annotation tool for annotating joints in video
function annotate(opts,f_idx)
global andata;

%load in joint annotations if present
data_filename = sprintf('%sjoint_annotation_videoNr%d.mat','',opts.video_num);
if exist(data_filename,'file')
    andata = load(data_filename);
    andata = andata.andata;
else
%setup data
    joints = opts.joints(:,:,opts.testingset);
    %normalise pose
    joints = bsxfun(@minus,joints,joints(:,1,:));
    joints = reshape(joints,14,length(opts.testingset));
    
    %do clustering
    andata.centroids = vgg_kmeans(joints,opts.seg.numposeclusters,'verbose',0);
    andata.joints = zeros(2,7,opts.seg.numposeclusters);
    %find poses closest to cluster centroids
    andata.frameidx = zeros(1,opts.seg.numposeclusters);
    [c_idx, c_dist] = vgg_nearest_neighbour(joints,andata.centroids);
    for c = 1:opts.seg.numposeclusters
        cluster_ids = find(c_idx==c);
        cluster_dist = c_dist(c_idx==c);
        [~,frame_idx] = min(cluster_dist);
        frame_idx = cluster_ids(frame_idx);
        
        while numel(frame_idx)==0
            r = floor(1+rand*opts.seg.numposeclusters);
            cluster_ids = find(c_idx==r);
            cluster_dist = c_dist(c_idx==r);
            [~,frame_idx] = min(cluster_dist);
            frame_idx = cluster_ids(frame_idx);
        end
        andata.frameidx(c) = opts.testingset(frame_idx);
    end
    andata.frameidx = sort(andata.frameidx);
    andata.completed = zeros(1,opts.seg.numposeclusters);
    andata.data_filename = data_filename;
%     andata.joints = opts.joints(:,:,andata.frameidx);
    andata.jclr = jet(7);
end

%load in images from video
video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
images = repmat(uint8(0),[opts.stdimgheight,opts.stdimgwidth,3,opts.seg.numposeclusters]);
for c = 1:opts.seg.numposeclusters
    I=mre_avifile(video_path,andata.frameidx(c)-1);
	images(:,:,:,c)=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
end

%get current frame to annotate
andata.current = find(andata.completed==0,1,'first');
if nargin==2
    andata.current = f_idx;
end

%create figure and handles
handle.fig = figure;
handle.img = imagesc(zeros(opts.stdimgheight,opts.stdimgwidth));
axis off; axis image;
hold on

%plot skeleton out of frame to initialise handles
for j = 1:7
    handle.plotj{j} = plot(0,0,'bo','markerfacecolor',andata.jclr(j,:),'markersize',10);
end

for l = 1:4
    handle.line{l} = plot([0,0],[0,0],'b-','color',andata.jclr(l,:),'linewidth',5);
end

handle.title = title(sprintf('frame %d of %d',andata.current,opts.seg.numposeclusters));
handle.btn_next = uicontrol('Style', 'pushbutton', 'String', 'Next',...
        'Position', [70 20 50 20],...
        'Callback',{@button_next,handle,images});
handle.btn_prev = uicontrol('Style', 'pushbutton', 'String', 'Prev',...
        'Position', [20 20 50 20],...
        'Callback',{@button_prev,handle,images});
handle.btn_prev = uicontrol('Style', 'pushbutton', 'String', 'Start',...
    'Position', [20 40 50 20],...
    'Callback',{@start_annotation,handle,images});
set(handle.fig,'KeyPressFcn',{@start_annotation,handle,images});

%display image
display_image(andata,handle,images);
