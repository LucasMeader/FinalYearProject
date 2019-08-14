close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patchesFlipped

source = '/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patchesFlipped/';

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1 :numel(D)
    subjectDCM = D(k).name;
    
    subject = erase(subjectDCM, '.dcm');
    
    subjectTIF = strcat(source, subject, '.tif');
    
    fullImageFilePath = fullfile(strcat(source, subject));
    
    fullImage = dicomread(fullImageFilePath);
    
    fullImage3d = repmat(fullImage, 1, 1, 3);
    
    imwrite(fullImage3d, subjectTIF);
    
    delete(subjectDCM);
    
end