close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/trainingSets/cancerous

source = '/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/trainingSets/cancerous/';

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)
    subject = D(k).name;
    
    fullImageFilePath = fullfile(strcat(source, subject));
    
    fullImage = imread(fullImageFilePath);
    
    imgInfo = imfinfo(fullImageFilePath);
    
    imageWidth = imgInfo.Width;
    imageHeight = imgInfo.Height;
    
    is3d = size(fullImage(:,:,:));
    is3d = numel(is3d);
    if imageWidth ~= 227  || imageHeight ~= 227 || is3d < 3
        fprintf(subject);
        fprintf('\n');
%         imageWidth
%         fprintf('\n');
%         imageHeight
%         fprintf('\n');
    end
    

end