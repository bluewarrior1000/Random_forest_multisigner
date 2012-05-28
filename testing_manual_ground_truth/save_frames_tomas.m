addpath('../random_forest/')
init_options_colourmodel_62_save;

%using repmat because  when using the function "zeros" matlab creates 
%a double matrix before conterting it to uint8
images = repmat(uint8(0),[opts.stdimgheight, opts.stdimgwidth, 3, length(opts.trainingset)]);

%load  segmentations provided by tomas
segdata = load(sprintf('%stomas_seg_videoNr%d.mat',opts.data_dir,opts.video_num));

%load in video
video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
vi=mre_avifile(video_path,'info');

%load tomas templates
load(sprintf('%svideoToColor_v2.mat',opts.data_dir))
ref.face = [];
ref.torso = [];
for template_id = 1:numel(videoToColor{opts.video_num})
    if (~isempty(videoToColor{opts.video_num}(template_id).face))
        face = videoToColor{opts.video_num}(template_id).face;
        torso = videoToColor{opts.video_num}(template_id).torso;
        face = reshape(face,[size(face,1)*size(face,2),1,3]);
        torso = reshape(torso,[size(torso,1)*size(torso,2),1,3]);
        
        ref.face = cat(1,ref.face, face);
        ref.torso = cat(1,ref.torso, torso);   
    end
end
MBf = ones(size(ref.face,1),size(ref.face,2)).*(sum(ref.face,3)~=0);
MBt = ones(size(ref.torso,1),size(ref.torso,2)).*(sum(ref.torso,3)~=0);
ref.face = uint8(ref.face);
ref.torso = uint8(ref.torso);
colour_hist{1} = smooth_normalise_hist(opts,mre_rgbhistogram(ref.face,opts.colourhist.bits,MBf));
colour_hist{2} = smooth_normalise_hist(opts,mre_rgbhistogram(ref.torso,opts.colourhist.bits,MBt));
% 
count = 0;
for i = 1:length(opts.testingset)
%     %load images
%     while count~=(opts.testingset(i)-1)
%         mre_avifile(video_path,count);
%         count = count + 1;
%         pause(0.005);
%     end
%     count = count +1;
    I=mre_avifile(video_path,opts.testingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    %compute background histogram
    C = compute_posterior(opts,I,colour_hist);
    S = double(segdata.seg(:,:,opts.testingset(i)));
    img_feat = cat(3,S.*C(:,:,1),...
                        S.*C(:,:,2),...
                        (1-S).*C(:,:,3));
    img_feat = bsxfun(@rdivide,img_feat,sum(img_feat,3)+eps); 
    images(:,:,:,i) = uint8(img_feat*255);
%      l = I; 
%      l(repmat(bwperim(S),[1 1 3])) = 1;
%      imagesc(l); axis image
% 
%      drawnow
%          pause
end
clear 'segdata';

switch opts.video_num
    case 47
        step = 4;
    case 62
        step = 4;
    otherwise
        step = 2;
end

images = images(:,:,:,1:step:end);
opts.testingset = opts.testingset(1:step:end);
save(sprintf('./frames/tomas/video%d/images.mat',opts.video_num),'-v7.3','images');
save(sprintf('./frames/tomas/video%d/testingset.mat',opts.video_num),'opts');