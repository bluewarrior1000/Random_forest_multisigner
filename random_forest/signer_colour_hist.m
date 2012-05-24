%learn signer colour model
function colour_hist = signer_colour_hist(opts)
    %check if global colour model present
    if exist([opts.feature_dir '\' opts.colourhist.filename],'file')
        error('colour histogram model already present, delete if you would like to recompute')
        %load in histogram
        
    else %compute histogram
        bits = opts.colourhist.bits;
        colour_hist_head = zeros(2^bits,2^bits,2^bits,length(opts.colourhist.trainingset));
        colour_hist_torso = zeros(2^bits,2^bits,2^bits,length(opts.colourhist.trainingset));
        colour_hist_back = zeros(2^bits,2^bits,2^bits,length(opts.colourhist.trainingset));
        for image_num = 1:length(opts.colourhist.trainingset)
            %compute transformations of rectangles
            img_trans = compute_transformation(opts,image_num);

            %compute masks
            torso_mask = sum(cat(3,img_trans(2:6).deadzone),3)>0;    
            head_mask = img_trans(1).deadzone>0;
            background_mask = sum(cat(3,img_trans(:).deadzone),3)==0;
            background_mask = imerode(background_mask,strel('disk',20));

            %compute colour histograms
            img = imread(sprintf('%sim%05.0f.png',opts.image_dir,opts.colourhist.trainingset(image_num)));
            torso_hist = mre_rgbhistogram(img,opts.colourhist.bits,torso_mask);   
            head_hist = mre_rgbhistogram(img,opts.colourhist.bits,head_mask);
            background_hist = mre_rgbhistogram(img,opts.colourhist.bits,background_mask);

            %smooth and normalise histograms
            torso_hist = smooth_normalise_hist(opts,torso_hist);
            head_hist = smooth_normalise_hist(opts,head_hist);
            background_hist = smooth_normalise_hist(opts,background_hist);
            
            
            %segment image into head-hands/background regions and recompute
            %histograms (assume equal prior)
            likelihood = zeros(opts.imgheight,opts.imgwidth,3);
            likelihood(:,:,1) = mre_rgblookup(img,torso_hist);
            likelihood(:,:,2) = mre_rgblookup(img,head_hist);
            likelihood(:,:,3) = mre_rgblookup(img,background_hist);

            [~, class] = max(likelihood,[],3);
            head_seg = (class==2).*(~background_mask);
            torso_seg = (class==1).*(~background_mask);
            
            %recompute histogram for hands and head
            colour_hist_head(:,:,:,image_num) = smooth_normalise_hist(opts,mre_rgbhistogram(img,opts.colourhist.bits,head_seg));
            colour_hist_torso(:,:,:,image_num) = smooth_normalise_hist(opts,mre_rgbhistogram(img,opts.colourhist.bits,torso_seg));
            colour_hist_back(:,:,:,image_num) = background_hist;
        end
        head_hist = mean(colour_hist_head,4);
        torso_hist = mean(colour_hist_torso,4);
        background_hist = mean(colour_hist_back,4);
        
        %recompute likelihoods
        for image_num = 1:length(opts.colourhist.saveset)
            img = imread(sprintf('%sim%05.0f.png',opts.image_dir,opts.colourhist.saveset(image_num)));
            likelihood = zeros(opts.imgheight,opts.imgwidth,3);
            
            likelihood(:,:,1) = mre_rgblookup(img,torso_hist)*opts.colourhist.weight(1);
            likelihood(:,:,2) = mre_rgblookup(img,head_hist)*opts.colourhist.weight(2);
            likelihood(:,:,3) = mre_rgblookup(img,background_hist)*opts.colourhist.weight(3);
            posterior = uint8(round(likelihood./repmat(sum(likelihood,3),[1 1 3])*255));
            
            %save posterior in features folder
%             imwrite(posterior,sprintf('%sim%05.0f.png',opts.feature_dir,opts.colourhist.saveset(image_num)));
            
            if 1 %visualisation
                [~, class] = max(posterior,[],3);
                figure(1)
                imagesc(posterior); axis image
                figure(2)
                imagesc(class); axis image
                pause
            end
        end
        
    end

    %computes transformation matrices
    function img_trans = compute_transformation(opts,image_num)
        image_num = opts.colourhist.trainingset(image_num);
        for part = 1:6
            canonical = ones(opts.can_height(part),opts.can_width(part));
            %position head part
            if part==1
                coords = opts.joints(opts.table_part(part,:),1:2,image_num);
                diff = (coords(1,:)-coords(2,:));
                diff = diff/sqrt(sum(diff.^2));
                X = [[coords(1,1), coords(1,2)]; [coords(1,1) - opts.can_height(part)/2*diff(1), coords(1,2) - opts.can_height(part)/2*diff(2)]];
                diff = diff/sqrt(sum(diff.^2));
                X = [X; [X(1,1) + diff(2)*5, X(1,2) - diff(1)*5]];
                U = [[opts.can_width(part)/2, opts.can_height(part)/2]; [opts.can_width(part)/2, opts.can_height(part)]];
                U = [U; [ (U(1,1) - 5), U(1,2)]];
            %position arms 
            elseif (part >= 2 && part <= 5)
                coords = opts.joints(opts.table_part(part,:),1:2,image_num);
                diff = (coords(1,:)-coords(2,:));
                diff = diff/sqrt(sum(diff.^2));
                X = [coords; [coords(1,1) + diff(2)*5, coords(1,2) - diff(1)*5]];
                can_coords = [opts.can_width(part)/2, (1-opts.limb_pc)*opts.can_height(part); opts.can_width(part)/2, opts.limb_pc*opts.can_height(part)]; 
                U = [can_coords; [ (can_coords(1,1) - 5), can_coords(1,2)]];
            %position torso    
            else
                coords = opts.joints(7:8,1:2,image_num);
                diff = (coords(1,:)-coords(2,:));
                diff = diff/sqrt(sum(diff.^2));
                X = [coords; [coords(1,1) + diff(2)*5, coords(1,2) - diff(1)*5]];
                U = [[1,1]; [opts.can_width(part), 1]];
                U = [U; [U(1,1), U(1,2)+5]];
            end

            t_concord = cp2tform(X,U,'affine');
            T = t_concord.tdata.Tinv;
            [Xm Ym]=meshgrid(1:opts.can_width(part),1:opts.can_height(part));
            Cs=[Xm(:) Ym(:) ones(numel(Ym),1)]';
            img_trans(part).img2can = single(T'*Cs);

            T = t_concord.tdata.T;
            [Xm Ym]=meshgrid(1:opts.imgwidth,1:opts.imgheight);
            Cs=[Xm(:) Ym(:) ones(numel(Ym),1)]';
            img_trans(part).can2img= single(T'*Cs);

            Cs2 = double(img_trans(part).can2img);        
            img_trans(part).deadzone =  uint8(reshape((vgg_interp2(canonical,Cs2(1,:),Cs2(2,:))),[opts.imgheight opts.imgwidth 1]));
        end    
        
    %smooth and normalise histogram
    function histogram = smooth_normalise_hist(opts, histogram)
        histogram = gauss3d(histogram,opts.colourhist.smoothvariance,0);
        histogram = histogram/sum(histogram(:)); %normalise
        histogram = histogram + opts.colourhist.R;
        histogram = histogram/sum(histogram(:));
        