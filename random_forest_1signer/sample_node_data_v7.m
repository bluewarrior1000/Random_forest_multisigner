%SAMPLE_NODE_DATA - samples test functions and features for node
%V4 - uses vectorised code
%v5 - further improvement on vectorised code
%v6 - is more memory efficient
%v7 - more memory efficent than v6
function [feature, offset, channel] = sample_node_data_v7(opts,WI,data,images,func_type,f1,f2,o1,o2)
    func = func_pointer_v2(func_type);
    channel = floor(rand*opts.numchannels + 1);
    if nargin<=5
        data_img_index = double(data.img_index(WI));
        data_x = double(data.x(WI));
        data_y = double(data.y(WI));
        feature = zeros(opts.numsampletests,size(WI,2));
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
                index1 =  uint32((double(opts.imgwidth*opts.imgheight))*((data_img_index-1)*opts.numchannels + (channel-1))  + (double(opts.imgheight)*(data_x+offset(i,ones(1,size(WI,2)))-1)) + (data_y+offset(i,2*ones(1,size(WI,2)))));
                feature(i,:) = images.frames(index1(:))';
            end     
        else %binary function
            %sample offsets
            offset = double(floor(rand(opts.numsampletests,4)*(opts.windowwidth)) +1 - (opts.windowwidth+1)/2);
            for i =1:opts.numsampletests
                index1 =  uint32((double(opts.imgwidth*opts.imgheight))*((data_img_index-1)*opts.numchannels + (channel-1))  + (double(opts.imgheight)*(data_x+offset(i,ones(1,size(WI,2)))-1)) + (data_y+offset(i,2*ones(1,size(WI,2)))));
                index2 =  uint32((double(opts.imgwidth*opts.imgheight))*((data_img_index-1)*opts.numchannels + (channel-1))  + (double(opts.imgheight)*(data_x+offset(i,3*ones(1,size(WI,2)))-1)) + (data_y+offset(i,4*ones(1,size(WI,2)))));
                value1 = images.frames(index1(:));
                value2 = images.frames(index2(:));
                feature(i,:) = func(double(value1),double(value2));
            end
        end
    else %this lets build_multiclass_tree generate one lot of features then apply different tests
        %rather than generating features for each type of test
        if func_type == 1
            feature = f1;
            offset = o1;
        else
            feature = zeros(opts.numsampletests,size(WI,2));
            for i = 1:opts.numsampletests
                feature(i,:) = func(f1(i,:)',f2(i,:)');
            end
            offset = o1;
            offset(:,3:4) = o2(:,1:2);
        end
    end
end