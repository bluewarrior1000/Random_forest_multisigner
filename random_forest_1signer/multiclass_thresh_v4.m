%MULTICLASS_THRESH - find multiclass threshold value for tree
%   T = multiclass_thresh(opts, data)
%   opts is the options structure
%   data is a 2 by N matrix for each class with on first row and N test 
%   results on second row
%   v2 - slightly faster version
%   v3 - allows a matrix to be used for feature (each row per offset)
%   v4 - loops over offsets to save memory
function [T, gmax, window_index_left, window_index_right,offset_idx] = multiclass_thresh_v4(opts,WI,data,feature)
    window_index_left = [];
    window_index_right = [];
    offset_idx = [];
    gmax = -inf;
    
    data_class = data.class(WI);
    data_weight = data.class_weight(data_class);
    num_samples = size(feature,2);
    HR = zeros(opts.numclasses, 1);
    HL = zeros(opts.numclasses, num_samples);
    bestfeature = 0;
    T=[];
    
    if num_samples<=opts.min_pernode
        T = []; %leaf node
    elseif numel(unique(data_class(1,:)))==1
        T = [];
    else %find threshold
        %TODO: for now assume a 256 bin histogram, but this should change
        %when binary features are used
        compare = (1:opts.numclasses)';
        compare = compare(:,ones(1,num_samples));
        
        H = histc(data_class,1:opts.numclasses);
        H = H(:).*data.class_weight';
        total_freq = sum(H);
        
        for i = 1:opts.numsampletests
            G = 0;
            [sorted_data, idxc] = sort(feature(i,:),2);
            sorted_class = data_class(idxc);
            sorted_weight = data_weight(idxc);
            binary = sorted_class(ones(opts.numclasses,1),:)==compare;
            w_binary = binary.*sorted_weight(ones(opts.numclasses,1),:);
            HL = cumsum(w_binary,2);
            norml = sum(HL);
            for s = 1:(num_samples-1)
                if sorted_data(s)~=sorted_data(s+1)
                    HR = H - HL(:,s);
                    G = sum(HL(:,s).^2)/norml(s) + sum(HR.^2)/(total_freq-norml(s));
                    if G>gmax
                        gmax = G;
                        T = sorted_data(s);
                        win_idx = s;
                        best_idxc = idxc;
                        offset_idx = i;
                    end
                end
            end
        end
        if ~isempty(T)
            window_index_left = WI(best_idxc(1:win_idx));
            window_index_right = WI(best_idxc((win_idx+1):num_samples));
            if T==1 || T==num_samples
                T=[];
                gmax = -inf;
            end
        end
        %if feature values all the same set as a leaf node
        %NOTE: cannot explicitly check for this as code is vectorised so
        %instead we check if the threshold splits the data into one big
        %chunck and the empty set
    end
end