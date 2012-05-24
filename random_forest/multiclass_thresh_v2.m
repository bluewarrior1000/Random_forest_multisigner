%MULTICLASS_THRESH - find multiclass threshold value for tree
%   T = multiclass_thresh(opts, data)
%   opts is the options structure
%   data is a 2 by N matrix for each class with on first row and N test 
%   results on second row
%   v2 - slightly faster version
function [T, gmax, window_index_left, window_index_right, CDL, CDR] = multiclass_thresh_v2(opts,window_index)
    global feature;
    global data;
    window_index_left = [];
    window_index_right = [];
        
    gmax = -inf;
    
    data_class = data.class(window_index);
    num_samples = size(feature.feature_val,2);
    
    if num_samples<=opts.min_pernode
        T = -1; %leaf node
    elseif numel(unique(data_class))==1
        T = -1;
    else %find threshold
        T = -1;
        [sorted_data, idx_c] = sort(feature.feature_val,2);
        sorted_class = data_class(idx_c);
        class_distribution_left = zeros(1,opts.numclasses);
        class_distribution_right = hist(sorted_class,1:opts.numclasses);
        for NL = 1:(num_samples-1)
            class = sorted_class(NL);
            class_distribution_left(class) = (class_distribution_left(class) +1);
            class_distribution_right(class) = (class_distribution_right(class) -1);
            
            if sorted_data(NL)~=sorted_data(NL+1)
                NR = num_samples-NL;
                g = sum((class_distribution_left).^2)/NL + sum((class_distribution_right).^2)/NR;
                if g>gmax
                    gmax = g;
                    T = sorted_data(NL);
                    window_index_left = 1:NL;
                    window_index_right = (NL+1):num_samples;
                end                
            end
        end
        window_index_left = window_index(idx_c(window_index_left));
        window_index_right = window_index(idx_c(window_index_right));
    end
    
end