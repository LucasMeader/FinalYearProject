close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bUseful

wrongType = cell(122727,1);

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 197:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    patchCreatedCCL = 0;
    patchCreatedCCR = 0;
    patchCreatedMLOL = 0;
    patchCreatedMLOR = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bUseful/', subject);
    cd(infoFileName)
    % CC 
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('CCpair exists\n');
        cd('CCpair')
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % 7 means its a folder and exists          
            cd('left')
            fprintf('left CC folder exists\n');
            mkdir croppedProSpotImage;
            cd('spotImage');
            a = dir('*.dcm');
            numberOfDCMInFolder = numel(a);
            for file = 1:numberOfDCMInFolder
                imageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/spotImage/', a(file).name));
                dicomInfo = dicominfo(imageFilePath);
                
                presentationIntentType = string(dicomInfo.PresentationIntentType);
                presentationFlag = strfind(presentationIntentType, 'PRESENTATION');
                                
                if presentationFlag > 0
                    patchName = strcat('cropped.', a(file).name);
                    patchPath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/croppedProSpotImage/', patchName));
                    dicomImage = dicomread(imageFilePath);
                    newPatch = imcrop(dicomImage, []);
                    TF = isempty(newPatch);
                    if TF == 0 
                        dicomwrite(newPatch, patchPath, dicomInfo, 'CreateMode', 'copy');
                        patchCreatedCCL = 1;
                    end
                end 
            end        
            cd ..
            if patchCreatedCCL == 0 & patchCreatedCCL == 0
                rmdir croppedProSpotImage
            end
            cd ..
        else 
            fprintf('No CC left folder\n');
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % 7 means its a folder and exists            
            cd('right')
            fprintf('right CC folder exists\n');
            mkdir croppedProSpotImage;
            cd('spotImage');
            a = dir('*.dcm');
            numberOfDCMInFolder = numel(a);
            for file = 1:numberOfDCMInFolder
                imageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/spotImage/', a(file).name));
                dicomInfo = dicominfo(imageFilePath);
                
                presentationIntentType = string(dicomInfo.PresentationIntentType);
                presentationFlag = strfind(presentationIntentType, 'PRESENTATION');
                  
                if presentationFlag > 0             
                    patchName = strcat('cropped.', a(file).name);
                    patchPath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/croppedProSpotImage/', patchName));
                    dicomImage = dicomread(imageFilePath);
                    newPatch = imcrop(dicomImage, []);
                    TF = isempty(newPatch);
                    if TF == 0                     
                        dicomwrite(newPatch, patchPath, dicomInfo, 'CreateMode', 'copy');
                        patchCreatedCCR = 1;
                    end
                end          
            end      
            cd ..
            if patchCreatedCCR == 0 & patchCreatedCCR == 0
                rmdir croppedProSpotImage
            end
            cd ..
        else
            fprintf('No CC right folder\n')    
        end    
        cd ..
    end
    % MLO 
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % 7 means its a folder and exists            
            cd('left')
            fprintf('left MLO folder exists\n');
            mkdir croppedProSpotImage;
            cd('spotImage');
            a = dir('*.dcm');
            numberOfDCMInFolder = numel(a);
            for file = 1:numberOfDCMInFolder
                imageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/spotImage/', a(file).name));
                dicomInfo = dicominfo(imageFilePath);
                 
                presentationIntentType = string(dicomInfo.PresentationIntentType);
                presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                if presentationFlag > 0
                    patchName = strcat('cropped.', a(file).name);
                    patchPath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/croppedProSpotImage/', patchName));
                    dicomImage = dicomread(imageFilePath);
                    newPatch = imcrop(dicomImage, []);
                    TF = isempty(newPatch);
                    if TF == 0   
                        dicomwrite(newPatch, patchPath, dicomInfo, 'CreateMode', 'copy');
                        patchCreatedMLOL = 1;
                    end
                end            
            end    
            cd ..
            if patchCreatedMLOL == 0 & patchCreatedMLOL == 0
                rmdir croppedProSpotImage
            end
            cd ..
        else
            fprintf('No MLO left folder\n');
        end
        % MLO RIGHT
        if isequal(exist('right', 'dir'),7) % 7 means its a folder and exists           
            cd('right')
            fprintf('right MLO folder exists\n');
            mkdir croppedProSpotImage;
            cd('spotImage');
            a = dir('*.dcm');
            numberOfDCMInFolder = numel(a);
            for file = 1:numberOfDCMInFolder
                imageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/spotImage/', a(file).name));
                dicomInfo = dicominfo(imageFilePath);
                 fprintf('were here!');
                presentationIntentType = string(dicomInfo.PresentationIntentType);
                presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                if presentationFlag > 0
                    fprintf('now were here!');
                    patchName = strcat('cropped.', a(file).name);
                    patchPath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/croppedProSpotImage/', patchName));
                    dicomImage = dicomread(imageFilePath);
                    newPatch = imcrop(dicomImage, []);
                    TF = isempty(newPatch);
                    if TF == 0   
                        dicomwrite(newPatch, patchPath, dicomInfo, 'CreateMode', 'copy');
                        patchCreatedMLOR = 1;
                    end
                end
            end  
            cd ..
            if patchCreatedMLOR == 0 & patchCreatedMLOR == 0
                rmdir croppedProSpotImage
            end            
        else
            fprintf('No MLO right folder\n');
        end        
    end
    if     patchCreatedCCL == 0 & patchCreatedCCR == 0 & patchCreatedMLOL == 0 & patchCreatedMLOR == 0
        wrongType{k} = subject;
    end    
end