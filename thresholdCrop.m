close all
clear all

spotView = dicomread('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Lucas/ImagePairs/Malignant/SpotCompression/demd21/CCpair/SpotImage/1.2.826.0.1.3680043.9.3218.1.1.26950057.4962.1510228559379.720.0.dcm');

thresholdValue = 100;
binaryImage = spotView > thresholdValue; % Bright objects will be chosen if you use >.

binaryImage = imfill(binaryImage, 'holes');

[L, n] = bwlabel(binaryImage);

regions = regionprops(L, 'BoundingBox');

topLeftX = regions(2).BoundingBox(1);
topLeftY = regions(2).BoundingBox(2);
width = regions(2).BoundingBox(3);
hight = regions(2).BoundingBox(4);

%            rectangle                  top left             width hight
cropOfSpotView = imcrop(spotView,  [topLeftX topLeftY       width hight]);


imshow(cropOfSpotView, [])

% s = regionprops(spotView,'centroid');
% centroids = cat(1,s.Centroid);
% imshow(spotView)
% hold on
% plot(centroids(:,1),centroids(:,2),'b*')
% hold off

