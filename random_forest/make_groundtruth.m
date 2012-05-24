%MAKE_GROUNDTRUTH - uses Buehler method of tracking to form blobs around
%joint locations
function make_groundtruth(opts)
[m,n,~] = size(imread([opts.image_dir 'im0001.png']));
%for all images create the different types of features
se = strel('disk',2);
total_time = 0;
joint_patch = zeros(opts.patchsize,2,opts.numclasses,size(opts.joints,3));
for i = 1:size(opts.joints,3)
    t = tic;
    for j = 1:opts.numclasses
        blank_img = zeros(m,n);
        blank_img(opts.joints(j,2,i),opts.joints(j,1,i)) = 1;
        blank_img = imdilate(blank_img,se)>0;
        [r,c] = find(blank_img);
        joint_patch(:,1,j,i) = c;
        joint_patch(:,2,j,i) = r;        
    end
    total_time = toc(t)+total_time;
    if mod(i,400)==0
        avg_time = total_time/i;
        fprintf('img:%d processed, time to completion: %4.4fsecs\n',i,avg_time*(size(opts.joints,3)-i));
    end
end
filename = sprintf('%sjoint_patch.mat',opts.joint_dir);
save(filename,'joint_patch');