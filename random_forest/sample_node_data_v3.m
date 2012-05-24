%SAMPLE_NODE_DATA - samples test functions and features for node
%V3 - uses images in memory plus loades features in an image at a time
function feature = sample_node_data_v3(opts,window_index)
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
    
    data_img_index = data.img_index(window_index);
    data_x = data.x(window_index);
    data_y = data.y(window_index);
    
    %extract feature value to pass into test functions
    [~,img_idx_sort]= sort(data_img_index(:));
    image_idx_prev = opts.trainingset(data_img_index(img_idx_sort(1)));
    last_loaded_idx = 1;
    index_of_image = 1;
    for i = 1:num_windows_at_node
        image_idx = opts.trainingset(data_img_index(img_idx_sort(i)));
        if image_idx_prev ~= image_idx || i==num_windows_at_node
            if i==num_windows_at_node
                load_idx = img_idx_sort(last_loaded_idx:i);
                index_of_image = image_idx;
            else
                index_of_image = image_idx_prev;
                load_idx = img_idx_sort(last_loaded_idx:(i-1));
            end
            img = images.frames(:,:,index_of_image);
            if func_type==1
                feature.offsetx1 = offset(1);
                feature.offsety1 = offset(2);
                for window = 1:length(load_idx)
                    x = feature.offsetx1 + data_x(load_idx(window));
                    y = feature.offsety1 + data_y(load_idx(window));
                    feature.feature_val(load_idx(window)) = img(y,x);
                end
            else
               feature.offsetx1 = offset(1);
                feature.offsety1 = offset(2);
                feature.offsetx2 = offset(3);
                feature.offsety2 = offset(4);
                for window = 1:length(load_idx)
                    x1 = feature.offsetx1 + data_x(load_idx(window));
                    y1 = feature.offsety1 + data_y(load_idx(window));
                    x2 = feature.offsetx2 + data_x(load_idx(window));
                    y2 = feature.offsety2 + data_y(load_idx(window));
                    feature.feature_val(load_idx(window)) = func([img(y1,x1),img(y1,x1)]);
                end
            end

            last_loaded_idx = i;
            
            if 0 %visualise
                figure(1)
                clf
                imagesc(img); axis image; pause
            end
        end
        image_idx_prev = image_idx;
    end
end