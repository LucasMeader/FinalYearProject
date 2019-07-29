close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

wrongType = cell(122727,1);

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1 %1:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject);
    cd(infoFileName)
    % CC 
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('CCpair exists\n');         % Comment to consel 
        cd('CCpair')                        % move into CCpair folder
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists       
            cd('left')                      % move into it
            
            if isequal(exist('processedPair', 'dir'),7)
                fprintf('Processed Pair Exists');
                cd('processedPair');
                dcmFiles = dir('*.dcm');
                for currentFile = 1:2
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped.');
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', croppedSpotFileName))
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    else
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', fullImageFileName))
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [imageHight, imageWidth, imageDepth] = size(fullImage);
                    end
                end   
                jsonFiles = dir('*.json');
                for currentFile = 1:size(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                    end
                end

                jsonText = fileread('coordinates.json');
                coordinateStruct = jsondecode(jsonText);
                X1 = str2double(coordinateStruct.X1)
                X2 = str2double(coordinateStruct.X2)
                Y1 = str2double(coordinateStruct.Y1)
                Y2 = str2double(coordinateStruct.Y2)
                
                % Coordinate border for visualisation
                XI = [X1, X2, X2, X1, X1];
                YI = [Y1, Y1, Y2, Y2, Y1];
                
                %             rectangle            top left      width hight
                cropOfFullView = imcrop(fullImage,  [X1 Y1       X2-X1 Y2-Y1]);

                % Resize spotView image in   percentage
                %downSizedCroppedSpot = imresize(croppedSpot, 1);
                
                % Centre of the coordinate rectangle
                coordxCentre = ((X2+X1)/2);
                coordyCentre = ((Y2+Y1)/2);
                
                % Calculate SSD and NCC between Template and Image
                [I_SSD,I_NCC] = template_matching(croppedSpotImage,fullImage);
                
                % Find maximum correspondence in I_SDD image
                [cropxCentre, cropyCentre] = find(I_SSD == max(I_SSD(:)));
                
                deltaX = max(coordxCentre, cropxCentre) - min(coordxCentre, cropxCentre);
                deltaY = max(coordyCentre, cropyCentre) - min(coordyCentre, cropyCentre);

                distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                
                twoPI = 6.2831853071795865;
                rad2deg = 57.2957795130823209;
                theta = atan(deltaY/deltaX);
                if theta < 0.0
                    theta = theta+twoPI ;
                end
                thetaInDegrees = rad2deg*theta
                
                figure, % Display image with location of desired profile lines
                imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropyCentre, cropyCentre], [imageHight, 0]); hold on; line([0, imageWidth], [cropxCentre, cropxCentre]); hold on; plot(cropyCentre,cropxCentre,'bo'); hold on; plot(coordyCentre, coordxCentre, 'go');%hold on; plot(XI, YI, 'g-', 'LineWidth', 1);
                colorbar;
%                 figure,
%                 subplot(2,1,1), improfile(I_SSD, [coordxCentre, coordxCentre], [imageHight, 0]); title('X Profile');
%                 subplot(2,1,2), improfile(I_SSD, [0, imageWidth], [coordyCentre, coordyCentre]); title('Y Profile');
%                 figure,
%                 subplot(2,1,1), imshow(cropOfFullView, []); title('Coordinate Patch');
%                 subplot(2,1,2), imshow(croppedSpotImage, []); title('Spot Patch');
                %cd .. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            end        
           
            cd ..
            
        else 
            fprintf('No CC left folder\n');
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists       
            cd('right')                      % move into it
            mkdir processedPair             % make a folder called processedPair for the crop and full image to go into
            fprintf('right CC folder exists\n');
            if isequal(exist('croppedProSpotImage', 'dir'),7)
                cd('croppedProSpotImage');
                dcmFiles = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
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
                dcmFiles = dir('*.dcm');
                
                numberOfDCMInFolder = numel(dcmFiles);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(dcmFiles(currentFile).name);
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
                dcmFiles = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
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
                dcmFiles = dir('*.dcm');
                
                numberOfDCMInFolder = numel(dcmFiles);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(dcmFiles(currentFile).name);
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
                dcmFiles = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
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
                dcmFiles = dir('*.dcm');
                
                numberOfDCMInFolder = numel(dcmFiles);
                for currentFile = 1:min(2, length(dcmFiles))
                    % Moving the processed full image to the processedPair
                    % folder
                    imageFilePath = string(dcmFiles(currentFile).name);
                    dicomInfo = dicominfo(imageFilePath);

                    presentationIntentType = string(dicomInfo.PresentationIntentType);
                    presentationFlag = strfind(presentationIntentType, 'PRESENTATION');

                    if presentationFlag > 0                     
                        imageFilePath = string(dcmFiles(currentFile).name);
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