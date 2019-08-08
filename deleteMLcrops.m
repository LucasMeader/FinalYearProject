close all
clear all

load('destArrayAbovefivehundred.mat');

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bmalignantMLpatches

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:254
    
    view = destArrayAbovefivehundred(k,2);
    if view == 1
        viewOrientation = '_CC_Left';
    elseif view == 2
        viewOrientation = '_CC_Right';
    elseif view == 3
        viewOrientation = '_MLO_Left';
    elseif view == 4
        viewOrientation = '_MLO_Right';
    end
    
    demdNumber = num2str(destArrayAbovefivehundred(k,1));
    
    fullFileName = fullfile(strcat('demd', demdNumber, viewOrientation))
    
    delete(fullFileName)
end