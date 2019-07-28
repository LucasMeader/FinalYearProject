
close all
clear all

%fileName = dicomread('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Lucas/ImagePairs/Malignant/demd11/MLOpair/fullImage/1.2.826.0.1.3680043.9.3218.1.1.26950057.4962.1510228559379.331.0.dcm');

%I = dicomread('/Users/lucasmeader/Desktop/optimam_data/magview_project/OPTIMAM/IMAGES/demd7541/1.2.826.0.1.3680043.9.3218.1.1.337078.8916.1512165599585.12485.0/1.2.826.0.1.3680043.9.3218.1.1.337078.8916.1512165599585.12490.0.dcm');

% Read DICOM header file asign to info variable
info = dicominfo('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/demd26/CCpair/left/spotImage/1.2.826.0.1.3680043.9.3218.1.1.26950057.4962.1510228559379.839.0.dcm');

% Extracting information from tables ('structs') within the header
% information using info>struct_name>item in the form info.struct_name.item
CCorMLOValue = info.ViewCodeSequence.Item_1.CodeValue
CCorMLOMeaning = info.ViewCodeSequence.Item_1.CodeMeaning
estimatedMagnification = info.EstimatedRadiographicMagnificationFactor
spotOrNotCodeValue = info.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeValue
spotOrNotCodeMeaning = info.ViewCodeSequence.Item_1.ViewModifierCodeSequence.Item_1.CodeMeaning


spacing = info.PixelSpacing;
per_pixel_area = spacing(1) * spacing(2);

