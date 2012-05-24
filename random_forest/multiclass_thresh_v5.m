%MULTICLASS_THRESH - find multiclass threshold value for tree
%   T = multiclass_thresh(opts, data)
%   opts is the options structure
%   data is a 2 by N matrix for each class with on first row and N test 
%   results on second row
%   v2 - slightly faster version
%   v3 - allows a matrix to be used for feature (each row per offset)
%   v4 - loops over offsets to save memory
%   v5 - no need to loop over offset as this is done within the main tree
%   building loop. Also, thresholds on quantised values. NOTE: have to pass in function type
function [T, Gmax, window_index_left, window_index_right] = multiclass_thresh_v5(opts,WI,data,feature,func_type)
    window_index_left = [];
    window_index_right = [];
    offset_idx = [];
    Gmax = -inf;
    
    data_class = data.class(WI);
%     data_weight = data.class_weight(data_class);
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
        switch func_type
            case 1
                num_edges = 256;
                addon = 1;
                thresh_lookup = 0:255;
            case 2
                num_edges = 511;
                addon = 256;
                thresh_lookup = -255:1:255;
            case 3
                num_edges = 256;
                addon = 1;
                thresh_lookup = 0:255;
            case 4
                num_edges = 511;
                addon = 1;
                thresh_lookup = 0:510;
            otherwise
                error('not a valid func type');
        end
        %form cumulative histogram
        HL = zeros(opts.numclasses,num_edges);
        
        for i = 1:num_samples
%                     disp(['data: ' num2str(data_class(i))]);
%         disp(['feature: ' num2str(feature(i)+addon)]);
            HL(data_class(i),feature(i)+addon) = HL(data_class(i),feature(i)+addon)+data.class_weight(data_class(i));
        end
        HL = cumsum(HL,2);
        HR = bsxfun(@minus,HL(:,end),HL);
        normL = sum(HL);
        normR = sum(HR);
        G = sum(HL.^2)./normL + sum(HR.^2)./normR;
        [Gmax, idxm] = max(G);

        if idxm~=1 || idxm==num_edges
            T = thresh_lookup(idxm);
            window_index_left = WI(feature<=T);
            window_index_right = WI(feature>T);
        end
    end
end