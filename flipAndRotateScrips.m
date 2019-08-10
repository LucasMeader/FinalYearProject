close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/benignMousePointExtraction

source = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/benignMousePointExtraction/'));
flippedSource = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/Flipped/'));
destinationFlipped = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/Flipped'));
destination90 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/Rotated90'));
destination180 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/Rotated180'));
destination270 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/Rotated270'));
destinationFlippedRotated90 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/FlippedAndRotated90'));
destinationFlippedRotated180 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/FlippedAndRotated180'));
destinationFlippedRotated270 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/FlippedAndRotated/FlippedAndRotated270'));


D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:171
    subject = D(k).name
    
    subject = erase(subject, '.dcm');
    
    % ------------ Rotate original image 90, 180 and 270 degrees and store
    % in new location  --------------------
    fprintf('you are in rotate');
    subject_r90 = fullfile(strcat(subject, '_r90.dcm'));
    subject_r180 = fullfile(strcat(subject, '_r180.dcm'));
    subject_r270 = fullfile(strcat(subject, '_r270.dcm'));
    
    fullImageFilePath = fullfile(strcat(source, subject));
    fullImageFilePath90 = fullfile(strcat(source, subject_r90));
    fullImageFilePath180 = fullfile(strcat(source, subject_r180));
    fullImageFilePath270 = fullfile(strcat(source, subject_r270));
    
    fullImage = dicomread(fullImageFilePath);
    imshow(fullImage, []);
    dicomInfo = dicominfo(fullImageFilePath);
    rotated90 = imrotate(fullImage, 90, 'bilinear', 'crop');
    rotated180 = imrotate(fullImage, 180, 'bilinear', 'crop');
    rotated270 = imrotate(fullImage, 270, 'bilinear', 'crop');
%     subplot(2,2,1), imshow(fullImage, []);
%     subplot(2,2,2), imshow(rotated90, []);
%     subplot(2,2,3), imshow(rotated180, []);
%     subplot(2,2,4), imshow(rotated270, []);
    
    dicomwrite(rotated90, subject_r90, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath90, destination90)
    
    dicomwrite(rotated180, subject_r180, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath180, destination180)
    
    dicomwrite(rotated270, subject_r270, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath270, destination270)     
    
    
    %--------------- flip original images --------------------------
    fprintf('you are in flip');
    subjectFlipped = strcat(subject, '_flipped.dcm'); % New file name for flipped image
    
    flippedFullImageFilePath = fullfile(strcat(source, subjectFlipped));
    
    % Flip on virtical axes
    flippedImage = flip(fullImage ,2);
    
    dicomwrite(flippedImage, subjectFlipped, dicomInfo, 'CreateMode', 'copy');
    movefile(flippedFullImageFilePath, destinationFlipped);     
    
    % ------------- Rotate the flipped images ----------------------
    fprintf('you are in rf');
    subject_fr90 = fullfile(strcat(subject, '_fr90.dcm'));
    subject_fr180 = fullfile(strcat(subject, '_fr180.dcm'));
    subject_fr270 = fullfile(strcat(subject, '_fr270.dcm'));
    
    fullImageFilePath = fullfile(strcat(source, subject));
    fullImageFilePathfr90 = fullfile(strcat(source, subject_fr90));
    fullImageFilePathfr180 = fullfile(strcat(source, subject_fr180));
    fullImageFilePathfr270 = fullfile(strcat(source, subject_fr270));
    
    fullImage = dicomread(fullImageFilePath);
    imshow(fullImage, []);
    dicomInfo = dicominfo(fullImageFilePath);
    frotated90 = imrotate(fullImage, 90, 'bilinear', 'crop');
    frotated180 = imrotate(fullImage, 180, 'bilinear', 'crop');
    frotated270 = imrotate(fullImage, 270, 'bilinear', 'crop');
%     subplot(2,2,1), imshow(fullImage, []);
%     subplot(2,2,2), imshow(rotated90, []);
%     subplot(2,2,3), imshow(rotated180, []);
%     subplot(2,2,4), imshow(rotated270, []);
    
    dicomwrite(frotated90, subject_fr90, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePathfr90, destinationFlippedRotated90)
    
    dicomwrite(frotated180, subject_fr180, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePathfr180, destinationFlippedRotated180)
    
    dicomwrite(frotated270, subject_fr270, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePathfr270, destinationFlippedRotated270) 
end