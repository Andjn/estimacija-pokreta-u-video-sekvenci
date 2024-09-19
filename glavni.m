clear all;
close all;

videoObj = VideoReader('C:\Program Files\MATLAB\R2017a\test.mp4');
refImg = rgb2gray(read(videoObj, 4));
currImg = rgb2gray(read(videoObj, 5));

BLK_SIZE = 8; 

tic;  
[motionVecX, motionVecY, predictImg] = motionEstimationOTA(currImg, refImg, BLK_SIZE, BLK_SIZE/2);
elapsedTime = toc;


disp(['Vreme izvr�enja funkcije motionEstimation: ', num2str(elapsedTime), ' sekundi']);

[r, c] = size(refImg);
[x, y] = meshgrid((1 : BLK_SIZE : c-BLK_SIZE+1), (1 : BLK_SIZE : r-BLK_SIZE+1));



mse = immse(currImg, predictImg);
disp(['Mean Squared Error: ', num2str(mse)]);

mae = mean(abs(currImg(:) - predictImg(:)));
disp(['Mean Absolute Error: ', num2str(mae)]);

imshow(refImg);
hold on;
quiver(x, y, motionVecX, motionVecY); 
 
figure;
imshow(currImg);
 
figure;
imshow(predictImg);

greska = currImg(:) - predictImg(:);
disp(['Maksimalna gre�ka: ', num2str(max(greska))]);


