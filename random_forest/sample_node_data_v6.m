%SAMPLE_NODE_DATA - samples test functions and features for node
%V4 - uses vectorised code
%v5 - further improvement on vectorised code
%v6 - is more memory efficient
function [feature, offset] = sample_node_data_v6(opts,WI,data,images,func_type)
%     func_type = floor(rand*opts.numtests +1);
    func = func_pointer_v2(func_type);
    
    data_img_index = double(data.img_index(WI));
    data_x = double(data.x(WI));
    data_y = double(data.y(WI));
    index1 = uint32(zeros(opts.numsampletests,size(WI,2)));
    index2 = uint32(zeros(opts.numsampletests,size(WI,2)));
    if size(WI,2) == 1
        data_x = data_x(:);
        data_y = data_y(:);
        data_img_index = data_img_index(:);
    end
    %TODO: try different types of sampling functions in window e.g. guassian
    %TODO: sampling offsets is done with replacement but should really bepl
    %done without replacement
    if func_type == 1 %unary function
        %sample offsets
        offset = double(floor(rand(opts.numsampletests,4)*(opts.windowwidth)) +1 - (opts.windowwidth+1)/2);
        %build index in for loop to save on memory
        for i = 1:opts.numsampletests
            index1(i,:) = uint32((double(opts.imgwidth*opts.imgheight))*(data_img_index-1) + (double(opts.imgheight)*(data_x+offset(i,ones(1,size(WI,2)))-1)) + (data_y+offset(i,2*ones(1,size(WI,2)))));
        end
        feature = reshape(images.frames(index1(:)),opts.numsampletests,size(WI,2));       
    else %binary function
        %sample offsets
        offset = double(floor(rand(opts.numsampletests,4)*(opts.windowwidth)) +1 - (opts.windowwidth+1)/2);
        for i =1:opts.numsampletests
            index1(i,:) =  uint32((double(opts.imgwidth*opts.imgheight))*(data_img_index-1) + (double(opts.imgheight)*(data_x+offset(i,ones(1,size(WI,2)))-1)) + (data_y+offset(i,2*ones(1,size(WI,2)))));
            index2(i,:) =  uint32((double(opts.imgwidth*opts.imgheight))*(data_img_index-1) + (double(opts.imgheight)*(data_x+offset(i,3*ones(1,size(WI,2)))-1)) + (data_y+offset(i,4*ones(1,size(WI,2)))));
        end
        value1 = double(images.frames(index1(:)));
        value2 = double(images.frames(index2(:)));
        feature = reshape(func(value1,value2),opts.numsampletests,size(WI,2));
    end
end