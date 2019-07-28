close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bUseful

wrongType = cell(122727,1);

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 196:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    cropMovedCCL = 0;
    cropMovedCCR = 0;
    cropMovedMLOL = 0;
    cropMovedMLOR = 0;
    fullImageMovedCCL = 0;
    fullImageMovedCCR = 0;
    fullImageMovedMLOL = 0;
    fullImageMovedMLOR = 0;
    noProPairCCL = 0;
    noProPairCCR = 0;
    noProPairMLOL = 0;
    noProPairMLOR = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bUseful/', subject);
    cd(infoFileName)
    % CC 
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('CCpair exists\n');         % Comment to consel 
        cd('CCpair')                        % move into CCpair folder
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists       
            cd('left')                      % move into it
            mkdir processedPair             % make a folder called processedPair for the crop and full image to go into
            fprintf('left CC folder exists\n');
            if isequal(exist('croppedProSpotImage', 'dir'),7)
                cd('croppedProSpotImage');
                a = dir('*.dcm');
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                    % Moving the corisponding json to the processedPair
                    % folder
                    jsonFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/spotImage/'));
                    [filepath,fileName,ext] = fileparts(imageFilePath);
                    newStr = erase(fileName, 'cropped.');
                    jsonFilePath = strcat(jsonFilePath, newStr, '.json');
                    copyfile(jsonFilePath, processedPairLocation);
                    
                    cropMovedCCL = 1;
                end
                cd ..
            end        
            
            if isequal(exist('fullImage', 'dir'),7)
                cd fullImage
                a = dir('*.dcm');
           
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0           
                        processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair'));
                        copyfile(imageFilePath, processedPairLocation);
                        % Moving the corisponding json to the processedPair
                        % folder
                        [filepath,fileName,ext] = fileparts(imageFilePath);

                        jsonFilePath = strcat(fileName, '.json');
                        copyfile(jsonFilePath, processedPairLocation);

                        fullImageMovedCCL = 1;
                    end
                end
                cd ..
            end
            if cropMovedCCL == 0 | fullImageMovedCCL == 0
                noProPairCCL = 1;
                rmdir processedPair s
            end
            cd ..
            
        else 
            fprintf('No CC left folder\n');
            noProPairCCL = 1;
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists       
            cd('right')                      % move into it
            mkdir processedPair             % make a folder called processedPair for the crop and full image to go into
            fprintf('right CC folder exists\n');
            if isequal(exist('croppedProSpotImage', 'dir'),7)
                cd('croppedProSpotImage');
                a = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                    % Moving the corisponding json to the processedPair
                    % folder
                    jsonFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/spotImage/'));
                    [filepath,fileName,ext] = fileparts(imageFilePath);
                    newStr = erase(fileName, 'cropped.');

                    jsonFilePath = strcat(jsonFilePath, newStr, '.json');
                    copyfile(jsonFilePath, processedPairLocation);
                    
                    cropMovedCCR = 1;
                end
                cd ..
            end        
            
            if isequal(exist('fullImage', 'dir'),7)
                cd fullImage
                a = dir('*.dcm');
                
                numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(a(file).name);
                        processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair'));
                        copyfile(imageFilePath, processedPairLocation);
                        % Moving the corisponding json to the processedPair
                        % folder
                        [filepath,fileName,ext] = fileparts(imageFilePath);

                        jsonFilePath = strcat(fileName, '.json');
                        copyfile(jsonFilePath, processedPairLocation);

                        fullImageMovedCCR = 1;
                    end
                end
                cd ..
            end
            
            if cropMovedCCR == 0 | fullImageMovedCCR == 0
                noProPairCCR = 1;
                rmdir processedPair s
            end 
            cd ..
        else
            fprintf('No CC right folder\n')  
            noProPairCCR = 1;
        end    
        cd ..
    end
    % MLO 
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists       
            cd('left')                      % move into it
            mkdir processedPair             % make a folder called processedPair for the crop and full image to go into
            fprintf('left MLO folder exists\n');
            if isequal(exist('croppedProSpotImage', 'dir'),7)
                cd('croppedProSpotImage');
                a = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                    % Moving the corisponding json to the processedPair
                    % folder
                    jsonFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/spotImage/'));
                    [filepath,fileName,ext] = fileparts(imageFilePath);
                    newStr = erase(fileName, 'cropped.');
                   
                    jsonFilePath = strcat(jsonFilePath, newStr, '.json');
                    copyfile(jsonFilePath, processedPairLocation);
                    
                    cropMovedMLOL = 1;
                end
                cd ..
            end        
            
            if isequal(exist('fullImage', 'dir'),7)
                cd fullImage
                a = dir('*.dcm');
                
                numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(a(file).name);
                        processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair'));
                        copyfile(imageFilePath, processedPairLocation);
                        % Moving the corisponding json to the processedPair
                        % folder
                        [filepath,fileName,ext] = fileparts(imageFilePath);
             
                        jsonFilePath = strcat(fileName, '.json');
                        copyfile(jsonFilePath, processedPairLocation);

                        fullImageMovedMLOL = 1;
                    end
                end
                cd ..
            end
            
            if cropMovedMLOL == 0 | fullImageMovedMLOL == 0
                noProPairMLOL = 1;
                rmdir processedPair s
            end
            cd ..
        else
            fprintf('No MLO left folder\n');
            noProPairMLOL = 1;
        end
        % MLO RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists       
            cd('right')                      % move into it
            mkdir processedPair             % make a folder called processedPair for the crop and full image to go into
            fprintf('left MLO folder exists\n');
            if isequal(exist('croppedProSpotImage', 'dir'),7)
                cd('croppedProSpotImage');
                a = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                    % Moving the corisponding json to the processedPair
                    % folder
                    jsonFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/spotImage/'));
                    [filepath,fileName,ext] = fileparts(imageFilePath);
                    newStr = erase(fileName, 'cropped.');
                    
                    jsonFilePath = strcat(jsonFilePath, newStr, '.json');
                    copyfile(jsonFilePath, processedPairLocation);
                    
                    cropMovedMLOR = 1;
                end
                cd ..
            end        
            
            if isequal(exist('fullImage', 'dir'),7)
                cd fullImage
                a = dir('*.dcm');
                
                numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(a(file).name);
                        processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair'));
                        copyfile(imageFilePath, processedPairLocation);
                        % Moving the corisponding json to the processedPair
                        % folder
                        [filepath,fileName,ext] = fileparts(imageFilePath);

                        jsonFilePath = strcat(fileName, '.json');
                        copyfile(jsonFilePath, processedPairLocation);

                        fullImageMovedMLOR = 1;
                    end
                end
                cd ..
            end
            if cropMovedMLOR == 0 | fullImageMovedMLOR == 0
                noProPairMLOR = 1;
                rmdir processedPair s
            end          
        else
            fprintf('No MLO right folder\n');
            noProPairMLOR = 1;
        end        
    end
%     if     noProPairCCL == 1 & noProPairCCR == 1 & noProPairMLOL == 1 & noProPairMLOR == 1
%         cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful
%         fileID = fopen('wrongTypeOfSpot.txt','w');
%         fprintf(fileID,'%6.2f %12.8f\n', subject);
%         fclose(fileID);
%     end    
end