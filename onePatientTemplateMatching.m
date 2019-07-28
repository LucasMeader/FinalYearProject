% code from: https://uk.mathworks.com/matlabcentral/fileexchange/24925-fast-robust-template-matching

close all
clear all

% Read in Spot Compression DICOM image
spotView = dicomread('/Users/lucasmeader/Desktop/1instanceOrganised/CC/Spot/Left/OPTIMAM_IMAGES_demd100092_1.2.826.0.1.3680043.9.3218.1.1.40492951.1482.1541647619877.150.0_1.2.826.0.1.3680043.9.3218.1.1.40492951.1482.1541647619877.158.0');

%            rectangle    top left   bottome right x,y
croppedSpot = imcrop(spotView,  [1 65       1021 836]);
% Resize spotView image in   percentage
downSizedSpot = imresize(croppedSpot, 0.25);

% Read in full DICOM image
fullView = dicomread('/Users/lucasmeader/Desktop/1instanceOrganised/CC/Full/Left/OPTIMAM_IMAGES_demd100092_1.2.826.0.1.3680043.9.3218.1.1.40492951.1482.1541647619877.123.0_1.2.826.0.1.3680043.9.3218.1.1.40492951.1482.1541647619877.135.0');
% code from: https://uk.mathworks.com/matlabcentral/fileexchange/24925-fast-robust-template-matching




% Allow user to select crop area
%T = imcrop(fullView, []);

% Resize croped area to desired scale
%J = imresize(T, 1);
   
% Calculate SSD and NCC between Template and Image
[I_SSD,I_NCC]=template_matching(downSizedSpot,fullView);

% Find maximum correspondence in I_SDD image
[x,y]=find(I_SSD==max(I_SSD(:)));

% Show result
figure, 
subplot(2,2,1), imshow(fullView, []); hold on; plot(y,x,'r*'); title('Result')
subplot(2,2,2), imshow(downSizedSpot, []); title('spot patch template');
subplot(2,2,3), imshow(I_SSD, []); title('SSD Matching');
subplot(2,2,4), imshow(I_NCC, []); title('Normalized-CC');