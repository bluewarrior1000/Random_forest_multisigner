clear opts

% opts.root='c:/data/leeds/james/buehler';
opts.root='.';

opts.vidnum=22;
opts.avi=sprintf('%s/video%d/x.avs',opts.root,opts.vidnum);

load(sprintf('%s/video%d/featMatSmoothed_videoNr%d',opts.root,opts.vidnum,opts.vidnum));
load(sprintf('%s/video%d/headMeanPosMat_videoNr%d',opts.root,opts.vidnum,opts.vidnum));
load(sprintf('%s/video%d/shoulderPosMat_videoNr%d',opts.root,opts.vidnum,opts.vidnum));

P=[headMeanPosMat(:,[2 1]) ...
featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
shoulderPosMat(:,[2 1 4 3])]';
P=reshape(P,2,[],size(P,2));
P(1,:,:)=P(1,:,:)*3+385;
P(2,:,:)=P(2,:,:)*3+55;
P=double(P);

for i=1:1:size(P,3)
    f=i-1;
    I=mre_avifile(opts.avi,f);
    I=I(1:2:end,:,:);
    I=imresize(I,[720*9/16 720],'bilinear');
    figure(1);
    imagesc(I);
    hold on;
    Pi=P(:,:,i);
    plot(Pi(1,1),Pi(2,1),'co','markersize',10,'linewidth',2);
    plot(Pi(1,[6 4 2]),Pi(2,[6 4 2]),'r-','linewidth',5);
    plot(Pi(1,[7 5 3]),Pi(2,[7 5 3]),'g-','linewidth',5);
    hold off;
    axis image;
    drawnow;
    
end
