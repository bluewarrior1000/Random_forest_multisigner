%MULTICLASS_THRESH - find multiclass threshold value for tree
%   T = multiclass_thresh(opts, data)
%   opts is the options structure
%   data is a 2 by N matrix for each class with on first row and N test 
%   results on second row
%   v2 - slightly faster version
%   v3 - allows a matrix to be used for feature (each row per offset)
function [T, gmax, window_index_left, window_index_right,offset_idx] = multiclass_thresh_v3(opts,WI,data,feature)
    window_index_left = [];
    window_index_right = [];
    offset_idx = [];
    gmax = -inf;
    
    data_class = data.class(WI);
    num_samples = size(feature,2);
    
    if num_samples<=opts.min_pernode
        T = []; %leaf node
    elseif numel(unique(data_class(1,:)))==1
        T = [];
    else %find threshold
        %TODO: for now assume a 256 bin histogram, but this should change
        %when binary features are used
        bins = (1:opts.numclasses)';
        [sorted_data, idxc] = sort(feature,2);
        col = idxc';
        col = col(:);
        
        row = repmat(1:opts.numsampletests,[1,num_samples]);
        row = row(:);
        ll = sub2ind(size(idxc),row,col);
        sorted_class = permute(reshape(data_class(ll),size(idxc)),[3 2 1]);
        binary = sorted_class(ones(opts.numclasses,1),:,:)==bins(:,ones(1,num_samples),ones(1,opts.numsampletests));
        HL = cumsum(binary,2);
        HR = repmat(permute(histc(sorted_class,1:8,2),[2,1,3]),[1,num_samples,1])-HL;
        norml = repmat(1:num_samples,[1,1,opts.numsampletests]);
        normr = repmat(num_samples:-1:1,[1,1,opts.numsampletests]);
        G = permute(sum(HL.^2)./norml + sum(HR.^2)./normr,[3,2,1]);
        [maxGs,idx_feature] = max(G);
        [gmax,idx_threshold] = max(maxGs);
        T = sorted_data(idx_feature(idx_threshold),idx_threshold);
        offset_idx = idx_feature(idx_threshold);
        window_index_left = WI(1,idxc(1,1:idx_threshold));
        window_index_right = WI(1,idxc(1,(idx_threshold+1):num_samples));
        
        %if feature values all the same set as a leaf node
        %NOTE: cannot explicitly check for this as code is vectorised so
        %instead we check if the threshold splits the data into one big
        %chunck and the empty set
        if idx_threshold==1 || idx_threshold==num_samples
            T=[];
            gmax = -inf;
        end
    end
end