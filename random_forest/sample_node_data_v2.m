%SAMPLE_NODE_DATA - samples test functions and features for node
%V2 - uses a the set of training images which have been loaded into memory
function feature = sample_node_data_v2(opts,window_index)
    global data; %window centres, classes and image indexes
    global images;
    %sample a test function to apply to feature values
    func_type = floor(rand*opts.numtests +1);
    func = func_pointer(func_type);

    num_windows_at_node = length(window_index);
    blank = uint8(0);
    feature = struct('offsetx1',blank,'offsety1',blank,'offsetx2',blank,...
        'offsety2',blank,'feature_val',single(zeros(1,num_windows_at_node)),...
        'func_type',func_type);
    
    %TODO: try different types of sampling functions in window e.g. guassian
    %TODO: sampling offsets is done with replacement but should really be
    %done without replacement
    if func_type == 1 %unary function
        %sample offsets
        offset = floor(rand(2,1)*opts.windowwidth - opts.windowwidth/2);
    else %binary function
        %sample offsets
        offset = floor(rand(4,1)*opts.windowwidth - opts.windowwidth/2);
    end

    data_x = data.x(window_index);
    data_y = data.y(window_index);
    
    %extract feature value to pass into test functions         
    if func_type==1
        feature.offsetx1 = offset(1);
        feature.offsety1 = offset(2);
        for window = 1:num_windows_at_node
            x = feature.offsetx1 + data_x(window);
            y = feature.offsety1 + data_y(window);
            feature.feature_val(window) = images.frames(y,x);
        end
    else
        feature.offsetx1 = offset(1);
        feature.offsety1 = offset(2);
        feature.offsetx2 = offset(3);
        feature.offsety2 = offset(4);
        for window = 1:num_windows_at_node
            x1 = feature.offsetx1 + data_x(window);
            y1 = feature.offsety1 + data_y(window);
            x2 = feature.offsetx2 + data_x(window);
            y2 = feature.offsety2 + data_y(window);
            feature.feature_val(window) = func([images.frames(y1,x1),images.frames(y2,x2)]);
        end
    end
end