clear all

classificationArray = cell(122727,1);

for a = 1:122727
    demdNumber = a
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateInfo/demd', num2str(demdNumber), '/NBSS_demd', num2str(demdNumber),'.json');
    imageFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateData/demd', num2str(demdNumber), '/NBSS_demd', num2str(demdNumber),'.json');

    fp = fopen(infoFileName,'r');
%if fp<1, error([msg ' File: ' fname]), end

    while fp >= 1
        raw = fread(fp); 
        str = char(raw');
        fclose(fp);
        val = jsondecode(str);
        
        classification = val.Classification;
        client = val.ClientID;
        
        classificationArray{a} = client;
        classificationArray{a+1} = classification;
        
        if classification == 'M'
            movefile infoFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateInfo/bMalignant;
            movefile imageFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateData/Malignant;
        elseif classification == 'B'
            movefile infoFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateInfo/Benign;
            movefile imageFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateData/Benign;
        else
            movefile infoFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateInfo/bUnknown;
            movefile imageFileName /vol/vssp/ucdatasets/mammo2/TotalRecall/LucasSeagateData/Unknown;
        end
        
        fp = 0;
    end
    
end
