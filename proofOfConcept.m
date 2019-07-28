close all

fullView = dicomread('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Lucas/ImagePairs/Malignant/SpotCompression/demd57/MLOpair/fullImage/1.2.826.0.1.3680043.9.3218.1.1.2695005.4962.1510228559379.1894.0.dcm');
spotView = dicomread('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Lucas/ImagePairs/Malignant/SpotCompression/demd57/MLOpair/spotImage/1.2.826.0.1.3680043.9.3218.1.1.2695005.4962.1510228559379.1921.0.dcm');

% Obtaining image size data
[imageHight, imageWidth, imageDepth] = size(fullView);

% Coordinates from json information file
X1 = 2232;
X2 = 2891;
Y1 = 2254;
Y2 = 2913;

% Coordinate border for visualisation
XI = [X1, X2, X2, X1, X1];
YI = [Y1, Y1, Y2, Y2, Y1];


%            rectangle            top left      width hight
cropOfFullView = imcrop(fullView,  [X1 Y1       X2-X1 Y2-Y1]);

% Allow user to select crop area
croppedSpot = imcrop(spotView, []);



% Resize spotView image in   percentage
downSizedCroppedSpot = imresize(croppedSpot, 1);

% Centre of the coordinate rectangle
xCentre = ((X2+X1)/2);
yCentre = ((Y2+Y1)/2);


% Calculate SSD and NCC between Template and Image
[I_SSD,I_NCC] = template_matching(downSizedCroppedSpot,fullView);

% Find maximum correspondence in I_SDD image
[x,y]=find(I_SSD == max(I_SSD(:)));

% Show result
% figure, 
% subplot(2,2,1), imshow(fullView, []); hold on; plot(y,x,'bo'); title('Result')
% subplot(2,2,2), imshow(downSizedSpot, []); title('spot patch template');
% subplot(2,2,3), 

figure, % Display image with location of desired profile lines
imshow(I_SSD, []); title('SSD Matching'); hold on; line([xCentre, xCentre], [imageHight, 0]); hold on; line([0, imageWidth], [yCentre, yCentre]); hold on; plot(y,x,'bo'); hold on; plot(XI, YI, 'g-', 'LineWidth', 1);
colorbar;
figure,
subplot(2,1,1), improfile(I_SSD, [xCentre, xCentre], [imageHight, 0]); title('X Profile');
subplot(2,1,2), improfile(I_SSD, [0, imageWidth], [yCentre, yCentre]); title('Y Profile');
figure,
subplot(2,1,1), imshow(cropOfFullView, []); title('Coordinate Patch');
subplot(2,1,2), imshow(downSizedCroppedSpot, []); title('Spot Patch');
% subplot(2,2,4), imshow(I_NCC, []); title('Normalized-CC');

similarity = dice(double(cropOfFullView), double(croppedSpot));
figure,
imshowpair(cropOfFullView, BW_groundTruth)
title(['Dice Index = ' num2str(similarity)])

% figure,
% imshow(fullView, []); hold on; plot(y,x,'bo'); hold on; plot(xCentre, yCentre, 'g*'); title('Result')
% subplot(1,2,2), imshow(cropOfFullView, []); title('Cropped patch');

 
 % figure,
% imshow(fullView, []); 
% hold on;
% plot(xCentre, yCentre, 'r*');

