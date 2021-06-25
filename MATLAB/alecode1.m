function posit2 = alecode1(nf)
pause(0.05);
background = uint8(imread("background.png"));

frame1 = sprintf( '%06d', nf-1 );
fim1 = rgb2gray(imread(append("record/"+frame1,".png")));
im1 = (abs(double(fim1)-double(background)))>0;
im1(3:15,65:150)=0;
posit2 = zeros(1,11);

  % Find centroids in the image1
    bw1 = imfill(im1,'holes');
    L1 = logical(bw1);
    s1 = regionprops(L1, 'centroid');
    C1 = cat(1, s1.Centroid);
    
        % Discard coners near the margin of the image
    ww = 20;
    w = round(ww/2);
    k = 1;
    for ii = 1:size(C1,1)
        x_i = C1(ii, 2);
        y_i = C1(ii, 1);
        if x_i-w>=1 && y_i-w>=1 && x_i+w<=size(im1,1)-1 && y_i+w<=size(im1,2)-1
          C(k,:) = round(C1(ii,:));
          k = k+1;
        end
    end
    
    for i = 1:size(C)
        if (C(i,1))>92 && (C(i,1))<97 % player in column 95  /210
            posit2(1)=C(i,2);
        elseif (C(i,2))>29 && (C(i,2))<35 % car in row 32    /320
            posit2(2)=C(i,1);
        elseif (C(i,2))>45 && (C(i,2))<50 % car in row 48
            posit2(3)=C(i,1);
        elseif (C(i,2))>61 && (C(i,2))<67 % car in row 64
            posit2(4)=C(i,1);
        elseif (C(i,2))>76 && (C(i,2))<84 % car in row 80
            posit2(5)=C(i,1);
        elseif (C(i,2))>94 && (C(i,2))<99 % car in row 96
            posit2(6)=C(i,1);
        elseif (C(i,2))>109 && (C(i,2))<115 % car in row 112
            posit2(7)=C(i,1);
        elseif (C(i,2))>125 && (C(i,2))<131 % car in row 128
            posit2(8)=C(i,1);
        elseif (C(i,2))>141 && (C(i,2))<147 % car in row 144
            posit2(9)=C(i,1);
        elseif (C(i,2))>157 && (C(i,2))<163 % car in row 160
            posit2(10)=C(i,1);
        elseif (C(i,2))>173 && (C(i,2))<179 % car in row 176
            posit2(11)=C(i,1);
        end
    end
    
%    for i = 1:size(C)
%        if (C(i,1))>92 && (C(i,1))<97 % player in column 95  /210
%            posit2(1)=C(i,2)/210;
%        elseif (C(i,2))>29 && (C(i,2))<35 % car in row 32    /320
%            posit2(2)=C(i,1)/320;
%        elseif (C(i,2))>45 && (C(i,2))<50 % car in row 48
%            posit2(3)=C(i,1)/320;
%        elseif (C(i,2))>61 && (C(i,2))<67 % car in row 64
%            posit2(4)=C(i,1)/320;
%        elseif (C(i,2))>76 && (C(i,2))<84 % car in row 80
%            posit2(5)=C(i,1)/320;
%        elseif (C(i,2))>94 && (C(i,2))<99 % car in row 96
%            posit2(6)=C(i,1)/320;
%        elseif (C(i,2))>109 && (C(i,2))<115 % car in row 112
%            posit2(7)=C(i,1)/320;
%        elseif (C(i,2))>125 && (C(i,2))<131 % car in row 128
%            posit2(8)=C(i,1)/320;
%        elseif (C(i,2))>141 && (C(i,2))<147 % car in row 144
%            posit2(9)=C(i,1)/320;
%        elseif (C(i,2))>157 && (C(i,2))<163 % car in row 160
%            posit2(10)=C(i,1)/320;
%        elseif (C(i,2))>173 && (C(i,2))<179 % car in row 176
%            posit2(11)=C(i,1)/320;
%        end
%    end
    
    
    writematrix(posit2,'positions.txt','Delimiter','tab');
    
%     %positions
%     positions=posit2;
%     imshow(im1);
%     hold on;
%     %plot(C(:,1), C(:,2), 'r*');
%     plot(95, positions(1), 'r*');
%     plot(positions(2),32,'b*');
%     plot(positions(3),48,'b*');
%     plot(positions(4),64,'b*');
%     plot(positions(5),80,'b*');
%     plot(positions(6),96,'b*');
%     plot(positions(7),112,'b*');
%     plot(positions(8),128,'b*');
%     plot(positions(9),144,'b*');
%     plot(positions(10),160,'b*');
%     plot(positions(11),176,'b*');


end
