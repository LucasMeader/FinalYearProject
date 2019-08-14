close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patches

source = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patches/'));
destinationFlipped = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patchesFlipped'));


D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)
    subject = D(k).name
    
    subject = erase(subject, '.dcm');
       
    %--------------- flip original images --------------------------
    fprintf('you are in flip');
    
    fullImageFilePath = fullfile(strcat(source, subject));
    
    fullImage = dicomread(fullImageFilePath);
    
    dicomInfo = dicominfo(fullImageFilePath);
    
    subjectFlipped = strcat(subject, '_flipped.dcm'); % New file name for flipped image
    
    flippedFullImageFilePath = fullfile(strcat(source, subjectFlipped));
    
    % Flip on virtical axes
    flippedImage = flip(fullImage ,2);
    
    dicomwrite(flippedImage, subjectFlipped, dicomInfo, 'CreateMode', 'copy');
    movefile(flippedFullImageFilePath, destinationFlipped);     
    
end