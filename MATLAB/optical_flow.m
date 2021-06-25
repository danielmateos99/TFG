clearvars;
close all;

% Size of the car ---> 15x9 pixels
% movement none=0 up=1 down=2 right=3 left=4
%movement = 1;

% Crear la imagen con el archivo background.m
background = uint8(imread("background.png"));

start_frame = 2;
end_frame = 400;

RGB = [0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 0.6 0.2; 0.5 0.5 0; 0 0.7 0.2; 0.5 0.5 0.5; 0.3 0 0.7; 0.7 0 0.3; 0.4 0.4 0.2; 0.8 0 1];


    fim1 = rgb2gray(imread(append("002873.png")));
    fim2 = rgb2gray(imread(append("002874.png")));
    im1 = (abs(double(fim1)-double(background)))>0;
    im2 = (abs(double(fim2)-double(background)))>0;

    % Find centroids in the image1
    bw1 = imfill(im1,'holes');
    L1 = logical(bw1);
    s1 = regionprops(L1, 'centroid');
    C1 = cat(1, s1.Centroid);
    
    % Find centroids in the image2
    bw2 = imfill(im2,'holes');
    L2 = logical(bw2);
    s2 = regionprops(L2, 'centroid');
    C2 = cat(1, s2.Centroid);

    % Discard coners near the margin of the image
    ww = 20;
    w = round(ww/2);
    k = 1;
    for ii = 1:size(C1,1)
        x_i = C1(ii, 2);
        y_i = C1(ii, 1);
        if x_i-w>=1 && y_i-w>=1 && x_i+w<=size(im1,1)-1 && y_i+w<=size(im1,2)-1
          C(k,:) = C1(ii,:);
          k = k+1;
        end
    end
    
    k = 1;
    for ii = 1:size(C2,1)
        x_i = C2(ii, 2);
        y_i = C2(ii, 1);
        if x_i-w>=1 && y_i-w>=1 && x_i+w<=size(im1,1)-1 && y_i+w<=size(im1,2)-1
          C_next(k,:) = C2(ii,:);
          k = k+1;
        end
    end
    
    % Labels
        labels = zeros(length(C(:,1)),4);
        labels(:,1)=C(:,1);
        labels(:,2)=C(:,2);

    % asegurar que los centroides de C son los mismos que los de labels
    temporal=1;
    for i=1:length(C(:,1))
        dist2 = sum(([labels(:,1) labels(:,2)] - C(i,:)) .^ 2, 2);
        closest = C(dist2 == 0,:);
        if length(closest(:,1))<1
            notinc(temporal,:) = C(i,:);
        end
    end
    temporal=1;
    for i=1:length(labels(:,1))
        dist2 = sum(([labels(i,1) labels(i,2)] - [labels(:,1) labels(:,2)]) .^ 2, 2);
        closest = C(dist2 == 0,:);
        if length(closest(:,1))>1
            labels(i,1)=notinc(temporal,1);
            labels(i,2)=notinc(temporal,2);
            temporal=temporal+1;

        end
    end
    
    
    vec_thresh = 25.000001;
    
    
    % fill labels_next
    labels(:,3)=zeros;
    labels(:,4)=zeros;
    
    gival=1;
    
    for i=1:length(labels(:,1))
        temporal = [labels(i,1) labels(i,2)];
        dist2 = sum((C_next - temporal) .^ 2, 2);
        closest = C_next(dist2 == min(dist2),:);
        if min(dist2)<vec_thresh
            labels(i,3) = closest(1,1);
            labels(i,4) = closest(1,2);
        else
            if gival>length(goingin(:,1))
                
            else
                labels(i,3) = goingin(gival,1);
                labels(i,4) = goingin(gival,2);
                gival=gival+1;
            end
            
        end
        
    end
    
    % going in
    goingin = [0 0];    
    %goingin = ones(abs(length(C(:,1))-length(C_next(:,1))),2);
    counter=1;
    for vec=1:length(C_next(:,1))
        dist2 = sum((C - C_next(vec,:)) .^ 2, 2);
        if min(dist2)>vec_thresh
            goingin(counter,:) = C_next(vec,:);
            counter=counter+1;
        end
    end
    
    %OF
    
    Ix_m = conv2(bw1,[-1 1; -1 1], 'valid'); % partial on x
    Iy_m = conv2(bw1, [-1 -1; 1 1], 'valid'); % partial on y
    It_m = conv2(bw1, ones(2), 'valid') + conv2(bw2, -ones(2), 'valid'); % partial on t
    u = zeros(length(C),1);
    v = zeros(length(C),1);

    % within window ww * ww
    for k = 1:length(C(:,2))
        i = C(k,2);
        j = C(k,1);
          Ix = Ix_m(i-w:i+w, j-w:j+w);
          Iy = Iy_m(i-w:i+w, j-w:j+w);
          It = It_m(i-w:i+w, j-w:j+w);

          Ix = Ix(:);
          Iy = Iy(:);
          b = -It(:); % get b here

          A = [Ix Iy]; % get A here
          nu = pinv(A)*b;
          
          u(k)=nu(1);
          v(k)=nu(2);
    end
    
    % Centroids
    
%     vec_thresh = 20.0001;
    
    uu = zeros(length(C(:,1)),1);
    vv = zeros(length(C(:,1)),1);
    for vec=1:length(C(:,1))
       dist2 = sum((C_next - C(vec,:)) .^ 2, 2);
       closest = C_next(dist2 == min(dist2),:);
       if exist('player','var')
           if C(vec,:) == player
               player_next = closest;
           end
       end
        
       if min(dist2)<vec_thresh
           uu(vec) = closest(1)-C(vec,1);
           vv(vec) = closest(2)-C(vec,2);
           
           
       end
    end
     
     % Example of error in case distance of centroids is 0
%      uu(3) = 0;
%      uu(4) = 0;
%      uu(6) = 0;
     
    for i=1:length(C(:,1))
        if abs(uu(i))<0.5 || abs(u(i))<0.5
            u(i) = 0;
        end
        if abs(vv(i))<0.5  || abs(v(i))<0.5           
            v(i) = 0;
        end
    end
     
    % DETECT PLAYER
     
     for i=1:length(C(:,1))
        if abs(u(i))<abs(v(i))
            player = C(i,:);
            player_next = C_next(i,:);
        end
     end
     
     
    % PLOT
    
    % background
    imshow(bw1);
    
    % Centroids
    hold on;
    plot(C(:,1), C(:,2), 'r*');
    plot(C_next(:,1), C_next(:,2), 'b*');

    % optical flow
    hold on;
    quiver(C(:,1), C(:,2), u,v, 1,'r')
    
    % boxes
    for i=1:length(labels(:,1))
        if exist('player','var')
            if [labels(i,1) labels(i,2)] == player
                str = [1 1 0];
            else
                str = [1 0 0];
            end
            quiver(C(:,1), C(:,2), u,v, 1,'r')
            %rectangle('Position',[[(labels(i,1)-8) (labels(i,2)-8)] 16 14],'EdgeColor',str);
        end
    end
    
    % UPDATE PLAYER
    if exist('player','var')
        player = player_next;
    end
    pause(0.1);


