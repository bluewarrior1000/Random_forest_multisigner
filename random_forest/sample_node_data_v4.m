%SAMPLE_NODE_DATA - samples test functions and features for node
%V4 - uses vectorised code
function [feature, offset, func_type] = sample_node_data_v4(opts,window_index,data,images)   
    %sample a test function to apply to feature values
    func_type = 3;%floor(rand*opts.numtests +1);
    func = func_pointer_v2(func_type);
    
    data_img_index = data.img_index(window_index);
    data_x = uint32(data.x(window_index));
    data_y = uint32(data.y(window_index));
    
    %TODO: try different types of sampling functions in window e.g. guassian
    %TODO: sampling offsets is done with replacement but should really be
    %done without replacement
    if func_type == 1 %unary function
        %sample offsets
        offset = uint32(floor(rand(4,1)*opts.windowwidth - opts.windowwidth/2));
        index1 = uint32(opts.imgwidth*opts.imgheight)*(data_img_index-1) + (opts.imgheight*(data_x+offset(1)-1)) + (data_y+offset(2));
        feature = images.frames(index1);
        %apply function
        
        
    else %binary function
        %sample offsets
        offset = uint32(floor(rand(4,1)*opts.windowwidth - opts.windowwidth/2));
        index1 = uint32(opts.imgwidth*opts.imgheight)*(data_img_index-1) + (opts.imgheight*(data_x+offset(1)-1)) + (data_y+offset(2));
        index2 = uint32(opts.imgwidth*opts.imgheight)*(data_img_index-1) + (opts.imgheight*(data_x+offset(2)-1)) + (data_y+offset(3));
        value1 = int32(images.frames(index1));
        value2 = int32(images.frames(index2));
        feature = func(value1,value2);
    end
end