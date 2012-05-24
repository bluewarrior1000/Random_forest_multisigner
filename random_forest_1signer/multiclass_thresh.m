%MULTICLASS_THRESH - find multiclass threshold value for tree
%   T = multiclass_thresh(opts, data)
%   opts is the options structure
%   data is a 2 by N matrix for each class with on first row and N test 
%   results on second row
function T = multiclass_thresh(opts, data)
    num_samples = size(data,2);
    if num_samples<=opts.min_pernode
        T = -1; %leaf node
    elseif numel(unique(data(2,:)))==1
        T = -1;
    else %find threshold
        [sorted_data, idx_c] = sort(data(2,:),2);
        sorted_class = data(1,idx_c);
        class_distribution_left = zeros(1,opts.numclasses);
        class_distribution_right = hist(sorted_class,1:opts.numclasses);
        gmin = inf;
        T = 1;
        for thresh = 1:(num_samples-1)
            class = sorted_class(thresh);
            class_distribution_left(class) = (class_distribution_left(class) +1);
            class_distribution_right(class) = (class_distribution_right(class) -1);
            
            if sorted_data(thresh)~=sorted_data(thresh+1)
                %update distributions according to thresh
                NR = num_samples-thresh;
                g = (1-sum((class_distribution_left/thresh).^2))*thresh + NR*(1-sum((class_distribution_right/NR).^2));
                if g<gmin
                    gmin = g;
                    T = sorted_data(thresh);
                end                
            end
        end
    end
end