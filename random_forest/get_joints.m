%returns joint locations based on joint classification predictions - dist
function [joints, dist] = get_joints(opts,dist)
    box = opts.boundingbox;
%     dist = bsxfun(@ldivide,sum(dist),dist); %normalise
    dist = reshape(dist',[box(4),box(3),8]);
    filt = fspecial('gaussian',4*6,4);
%     filt = fspecial('gaussian',10,8);
%     filt=1;
    joints = zeros(2,opts.numclasses-1);
    for c = 1:(opts.numclasses-1)
        dist(:,:,c) = imfilter(dist(:,:,c),filt); %apply smoothing
        [my, idxy]= max(dist(:,:,c)); %take point of maximum confidence
        [mx,x] = max(my);
        y = idxy(x);
        joints(:,c) = [x; y];
    end
end