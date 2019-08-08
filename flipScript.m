close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/b_combinedMLpatches_benign

source = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/b_combinedMLpatches_benign/'));
destination = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bFlipped'));


D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:94
    subject = D(k).name;
    
    subjectFlipped = erase(subject, '_flipped');
    
    fullImageFilePath = fullfile(strcat(source, subject));
    
    fullImage = dicomread(fullImageFilePath);
    imshow(fullImage, []);
    dicomInfo = dicominfo(fullImageFilePath);
    
    % Flip on virtical axes
    flippedImage = flip(fullImage ,2);
    
    newImage = dicomwrite(flippedImage, subjectFlipped, dicomInfo, 'CreateMode', 'copy');
    movefile(fullImageFilePath, destination);             

end