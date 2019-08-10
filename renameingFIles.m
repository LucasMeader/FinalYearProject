close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/trainingSets/benign

source = '/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/trainingSets/benign/';

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 6:numel(D)
    subject = D(k).name;
    
    fullImageFilePath = fullfile(strcat(source, subject));
    
    fullImage = imread(fullImageFilePath);
    
    fullImage3d = repmat(fullImage, 1, 1, 3);
    
    imwrite(fullImage3d, subject);
    
end