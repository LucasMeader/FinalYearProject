close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/b_combinedMLpatches_benign

source = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bFlipped/'));
destination90 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bFlippedAndRotated90'));
destination180 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bFlippedAndRotated180'));
destination270 = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bFlippedAndRotated270'));

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:94
    subject = D(k).name
    
    subject_r90 = fullfile(strcat(subject, '_fr90'));
    subject_r180 = fullfile(strcat(subject, '_fr180'));
    subject_r270 = fullfile(strcat(subject, '_fr270'));
    
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
    subplot(2,2,1), imshow(fullImage, []);
    subplot(2,2,2), imshow(rotated90, []);
    subplot(2,2,3), imshow(rotated180, []);
    subplot(2,2,4), imshow(rotated270, []);
    
    r90image = dicomwrite(rotated90, subject_r90, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath90, destination90)
    
    r180image = dicomwrite(rotated180, subject_r180, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath180, destination180)
    
    r270image = dicomwrite(rotated270, subject_r270, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath270, destination270)                    
    

end