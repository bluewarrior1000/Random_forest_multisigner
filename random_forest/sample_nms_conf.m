%function to sample maxima from the output of the Random Forest
function X = sample_nms_conf(opts,dist)
    se = ones(3,3);
    dilated_dist = imdilate(dist,se);
    maxima = dilated_dist==dist & dist>max(dist(:))/4;
    [r,c] = find(maxima);
    val = dist(maxima(:));
    [~,idx] = sort(val,'descend');
    X = [c(idx),r(idx)];