fullView = dicomread('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Lucas/ImagePairs/Malignant/demd11/MLOpair/fullImage/1.2.826.0.1.3680043.9.3218.1.1.26950057.4962.1510228559379.331.0.dcm');

X1 = 961;
X2 = 1146;
Y1 = 1624;
Y2 = 1840;

xCentre = ((X2-X1)/2)+X1;
yCentre = ((Y2-Y1)/2)+Y1;


figure,
imshow(fullView, []); 
hold on;
plot(xCentre, yCentre, 'r*');


%crop = imcrop(fullView, [694 1663 915 1808]);