% LAB
%------------
%script to store frames of video for training (so as not to rely on
%avisynth)
addpath('../random_forest/')
addpath('../training/')

init_options_colourmodel_62;
opts.frames_dir         = './frames/colourmodel_tomas/';
opts.forest_dir         = '../training/forests/colourmodel_tomas/';
opts.results_dir        = './results/colourmodel_tomas/';

video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
images = repmat(uint8(0),[opts.imgheight, opts.imgwidth, 3, length(opts.testingset)]);
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
    
for i = 1:length(opts.testingset)
    %load images
    I=mre_avifile(video_path,opts.testingset(i)-1);
    I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
    %add padding
    I = padarray(I,[opts.padding, opts.padding, 0],'symmetric','both');
    %compute background histogram
    images(:,:,:,i) = uint8(compute_posterior(opts,I,colour_hist)*255);
end

save(sprintf('%svideo%d/images.mat',opts.frames_dir,opts.video_num),'-v7.3','images');
save(sprintf('%svideo%d/testingset.mat',opts.frames_dir,opts.video_num),'opts');

