clear;
close all;

% Use frames of the game with movement to extract the backround
% by taking the color displayed more time in a pixel

videoframes = 1000;
image = rgb2gray(imread("000000.png"));
[x1,y1,z1] = size(image);
vid = zeros(x1,y1,videoframes);

for i=1:videoframes
    nframe = sprintf( '%06d', i );
    frame = rgb2gray(imread(append(nframe,".png")));
    vid(:,:,i) = frame;

end

bg = zeros(size(vid(:,:,1)));

for i=1:x1
    for j=1:y1
        bg(i,j) = mode(vid(i,j,:));
        
    end
end

imshow(uint8(bg));
imwrite(uint8(bg), "background.png");
