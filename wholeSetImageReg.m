close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

thetaArrayRads = zeros(618,2);
thetaArrayDegs = zeros(618,2);
distanceArray = zeros(618,4);

addedTotal = 1;

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    ccLeftAdded = 0;
    ccRightAdded = 0;
    mloLeftAdded = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject);
    cd(infoFileName);
    % CC
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        %fprintf('CCpair exists\n');         % Comment to consel
        cd('CCpair');                        % move into CCpair folder
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left');                      % move into it
            
            if isequal(exist('processedPair', 'dir'),7)
%                 fprintf('Processed Pair Exists\n');
                cd('processedPair');
                
                newFileName = fullfile(strcat(subject, '_CC', '_Left'));
                
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        subjectCoordFullImageNumber = coordinateStruct.fullImagePath;
                    end
                end
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'smallCropped');
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imrotate(croppedSpotImage, 7, 'bilinear', 'crop');
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    elseif tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        FX1 = str2double(coordinateStruct.X1);
                        FX2 = str2double(coordinateStruct.X2);
                        FY1 = str2double(coordinateStruct.Y1);
                        FY2 = str2double(coordinateStruct.Y2);
                        
                        % Coordinate border for visualisation
                        XFullBorder = [FX1, FX2, FX2, FX1, FX1];
                        YFullBorder = [FY1, FY1, FY2, FY2, FY1];
                        
                        %             rectangle            top left      width hight
                        fullViewCoordArea = imcrop(fullImage,  [FX1 FY1       FX2-FX1 FY2-FY1]);
                       
                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);
                        
                        % Centre of the coordinate rectangle
                        coordxCenter = ((FX2+FX1)/2);
                        coordyCenter = ((FY2+FY1)/2);
                        
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                        
                        % Find maximum correspondence in I_SDD image
                        [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                        
                        CX1 = cropxCenter - cropImageWidth/2;
                        CX2 = cropxCenter + cropImageWidth/2;
                        CY1 = cropyCenter - cropImageHight/2;
                        CY2 = cropyCenter + cropImageHight/2;
                        
                        % Coordinate border for visualisation
                        XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                        YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                        
                        %             rectangle            top left                 width hight
                        spotCropArea = imcrop(fullImage,  [CX1 CY1       cropImageWidth cropImageHight]);
                        
                        deltaX = max(coordxCenter, cropxCenter) - min(coordxCenter, cropxCenter);
                        deltaY = max(coordyCenter, cropyCenter) - min(coordyCenter, cropyCenter);
                        
                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                        
                        thetaInDegrees = atan2(cropyCenter-coordyCenter, cropxCenter-coordxCenter);
                        
                        %Add to arrays
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        %thetaArrayRads(addedTotal,2) = subjectDouble;
                        %thetaArrayRads(addedTotal,1) = theta;
                        thetaArrayDegs(addedTotal,2) = subjectDouble;
                        thetaArrayDegs(addedTotal,1) = thetaInDegrees;
                        distanceArray(addedTotal,4) = k;
                        distanceArray(addedTotal,3) = 1;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
%                     else
%                         fprintf('No coordinates');
%                         subjectDouble = str2double(erase(string(subject), 'demd'));
%                         noCoordinates(noCoordCount,1) = subjectDouble;
%                         noCoordCount = noCoordCount+1;
                    end
                end
                cd ..
            end
            cd ..     
%         else
%             fprintf('No CC left folder\n');
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists
            cd('right')                      % move into right folder
            
            if isequal(exist('processedPair', 'dir'),7)
                %fprintf('Processed Pair Exists\n');
                cd('processedPair');
                
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        subjectCoordFullImageNumber = coordinateStruct.fullImagePath;
                    end
                end
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'smallCropped');
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    elseif tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        FX1 = str2double(coordinateStruct.X1);
                        FX2 = str2double(coordinateStruct.X2);
                        FY1 = str2double(coordinateStruct.Y1);
                        FY2 = str2double(coordinateStruct.Y2);
                        
                        % Coordinate border for visualisation
                        XFullBorder = [FX1, FX2, FX2, FX1, FX1];
                        YFullBorder = [FY1, FY1, FY2, FY2, FY1];
                        
                        %             rectangle            top left      width hight
                        fullViewCoordArea = imcrop(fullImage,  [FX1 FY1       FX2-FX1 FY2-FY1]);
                       
                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);
                        
                        % Centre of the coordinate rectangle
                        coordxCenter = ((FX2+FX1)/2);
                        coordyCenter = ((FY2+FY1)/2);
                        
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                        
                        % Find maximum correspondence in I_SDD image
                        [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                        
                        CX1 = cropxCenter - cropImageWidth/2;
                        CX2 = cropxCenter + cropImageWidth/2;
                        CY1 = cropyCenter - cropImageHight/2;
                        CY2 = cropyCenter + cropImageHight/2;
                        
                        % Coordinate border for visualisation
                        XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                        YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                        
                        %             rectangle            top left                 width hight
                        spotCropArea = imcrop(fullImage,  [CX1 CY1       cropImageWidth cropImageHight]);
                        
                        deltaX = max(coordxCenter, cropxCenter) - min(coordxCenter, cropxCenter);
                        deltaY = max(coordyCenter, cropyCenter) - min(coordyCenter, cropyCenter);
                        
                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                        %                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('X Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('Y Profile');

                        thetaInDegrees = atan2(cropyCenter-coordyCenter, cropxCenter-coordxCenter);
                        
                        %Add to arrays
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        %thetaArrayRads(addedTotal,2) = subjectDouble;
                        %thetaArrayRads(addedTotal,1) = theta;
                        thetaArrayDegs(addedTotal,2) = subjectDouble;
                        thetaArrayDegs(addedTotal,1) = thetaInDegrees;
                        distanceArray(addedTotal,4) = k;
                        distanceArray(addedTotal,3) = 2;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('X Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('Y Profile');    
%                     else
%                         subjectDouble = str2double(erase(string(subject), 'demd'));
%                         noCoordinates(noCoordCount,1) = subjectDouble;
%                         noCoordCount = noCoordCount+1;
                    end
                end 
                cd ..
            end
            cd ..
%         else
%             fprintf('No CC right folder\n')
%             noProPairCCR = 1;
        end
        cd ..
    end
    % MLO
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        %fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left')                      % move into it
            
            if isequal(exist('processedPair', 'dir'),7)
                %fprintf('Processed Pair Exists\n');
                cd('processedPair');
                
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        subjectCoordFullImageNumber = coordinateStruct.fullImagePath;
                    end
                end
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'smallCropped');
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    elseif tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                jsonFiles = dir('*.json');
                for currentFile = 1:length(jsonFiles)
                    fileName = jsonFiles(currentFile).name;
                    coordinateFlag = strfind(fileName, 'coordinates');
                    if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        FX1 = str2double(coordinateStruct.X1);
                        FX2 = str2double(coordinateStruct.X2);
                        FY1 = str2double(coordinateStruct.Y1);
                        FY2 = str2double(coordinateStruct.Y2);
                        
                        % Coordinate border for visualisation
                        XFullBorder = [FX1, FX2, FX2, FX1, FX1];
                        YFullBorder = [FY1, FY1, FY2, FY2, FY1];
                        %                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('X Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('Y Profile');

                        %             rectangle            top left      width hight
                        fullViewCoordArea = imcrop(fullImage,  [FX1 FY1       FX2-FX1 FY2-FY1]);
                       
                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);
                        
                        % Centre of the coordinate rectangle
                        coordxCenter = ((FX2+FX1)/2);
                        coordyCenter = ((FY2+FY1)/2);
                        
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                        
                        % Find maximum correspondence in I_SDD image
                        [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                        
                        CX1 = cropxCenter - cropImageWidth/2;
                        CX2 = cropxCenter + cropImageWidth/2;
                        CY1 = cropyCenter - cropImageHight/2;
                        CY2 = cropyCenter + cropImageHight/2;
                        
                        % Coordinate border for visualisation
                        XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                        YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                        
                        %             rectangle            top left                 width hight
                        spotCropArea = imcrop(fullImage,  [CX1 CY1       cropImageWidth cropImageHight]);
                        
                        deltaX = max(coordxCenter, cropxCenter) - min(coordxCenter, cropxCenter);
                        deltaY = max(coordyCenter, cropyCenter) - min(coordyCenter, cropyCenter);
                        
                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                        
                        thetaInDegrees = atan2(cropyCenter-coordyCenter, cropxCenter-coordxCenter);
                        
                        %Add to arrays
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        %thetaArrayRads(addedTotal,2) = subjectDouble;
                        %thetaArrayRads(addedTotal,1) = theta;
                        thetaArrayDegs(addedTotal,2) = subjectDouble;
                        thetaArrayDegs(addedTotal,1) = thetaInDegrees;
                        distanceArray(addedTotal,4) = k;
                        distanceArray(addedTotal,3) = 3;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('X Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('Y Profile');
%                     else
%                         subjectDouble = str2double(erase(string(subject), 'demd'));
%                         noCoordinates(noCoordCount,1) = subjectDouble;
%                         noCoordCount = noCoordCount+1;
                    end
                end
                cd ..
            end
            cd ..
        end
%     else
%         fprintf('No MLO left folder\n');
%         noProPairMLOL = 1;
    end
    % MLO RIGHT
    if isequal(exist('right', 'dir'),7) % if left folder exists
        cd('right')                      % move into it
        
        if isequal(exist('processedPair', 'dir'),7)
%             fprintf('Processed Pair Exists\n');
            cd('processedPair');
            
            jsonFiles = dir('*.json');
            for currentFile = 1:length(jsonFiles)
                fileName = jsonFiles(currentFile).name;
                coordinateFlag = strfind(fileName, 'coordinates');
                if coordinateFlag > 0
                    coordinateFilePath = jsonFiles(currentFile).name;
                    jsonText = fileread('coordinates.json');
                    coordinateStruct = jsondecode(jsonText);
                    subjectCoordFullImageNumber = coordinateStruct.fullImagePath;
                end
            end
            
            dcmFiles = dir('*.dcm');
            for currentFile = 1:length(dcmFiles)
                fileName = dcmFiles(currentFile).name;
                cropFlag = strfind(fileName, 'smallCropped');
                tf = strcmp(subjectCoordFullImageNumber, fileName);
                if cropFlag > 0
                    croppedSpotFileName = dcmFiles(currentFile).name;
                    croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', croppedSpotFileName));
                    croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    %croppedSpotImage = imcrop(croppedSpotImage, []);
                    [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                    cropFlag = 0;
                elseif tf == 1
                    fullImageFileName = dcmFiles(currentFile).name;
                    fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', fullImageFileName));
                    fullImage = dicomread(fullImageFilePath);
                    % Obtaining image size data
                    [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                end
            end
            jsonFiles = dir('*.json');
            for currentFile = 1:length(jsonFiles)
                fileName = jsonFiles(currentFile).name;
                coordinateFlag = strfind(fileName, 'coordinates');
                if coordinateFlag > 0
                        coordinateFilePath = jsonFiles(currentFile).name;
                        
                        jsonText = fileread('coordinates.json');
                        coordinateStruct = jsondecode(jsonText);
                        FX1 = str2double(coordinateStruct.X1);
                        FX2 = str2double(coordinateStruct.X2);
                        FY1 = str2double(coordinateStruct.Y1);
                        FY2 = str2double(coordinateStruct.Y2);
                        
                        % Coordinate border for visualisation
                        XFullBorder = [FX1, FX2, FX2, FX1, FX1];
                        YFullBorder = [FY1, FY1, FY2, FY2, FY1];
                        
                        %             rectangle            top left      width hight
                        fullViewCoordArea = imcrop(fullImage,  [FX1 FY1       FX2-FX1 FY2-FY1]);
                       
                        % Resize spotView image in   percentage
                        %downSizedCroppedSpot = imresize(croppedSpot, 1);
                        
                        % Centre of the coordinate rectangle
                        coordxCenter = ((FX2+FX1)/2);
                        coordyCenter = ((FY2+FY1)/2);
                        
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                        
                        % Find maximum correspondence in I_SDD image
                        [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                        
                        CX1 = cropxCenter - cropImageWidth/2;
                        CX2 = cropxCenter + cropImageWidth/2;
                        CY1 = cropyCenter - cropImageHight/2;
                        CY2 = cropyCenter + cropImageHight/2;
                        
                        % Coordinate border for visualisation
                        XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                        YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                        
                        %             rectangle            top left                 width hight
                        spotCropArea = imcrop(fullImage,  [CX1 CY1       cropImageWidth cropImageHight]);
                        
                        deltaX = max(coordxCenter, cropxCenter) - min(coordxCenter, cropxCenter);
                        deltaY = max(coordyCenter, cropyCenter) - min(coordyCenter, cropyCenter);
                        
                        distanceBetweenCentres = sqrt(deltaX^2 + deltaY^2);
                        
                        thetaInDegrees = atan2(cropyCenter-coordyCenter, cropxCenter-coordxCenter);
                        
                        %Add to arrays
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        %thetaArrayRads(addedTotal,2) = subjectDouble;
                        %thetaArrayRads(addedTotal,1) = theta;
                        thetaArrayDegs(addedTotal,2) = subjectDouble;
                        thetaArrayDegs(addedTotal,1) = thetaInDegrees;
                        distanceArray(addedTotal,4) = k;
                        distanceArray(addedTotal,3) = 4;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        addedTotal = addedTotal+1;
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
%                         subplot(2,3,1), imshow(I_SSD, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         colorbar;
%                         subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
%                         subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)'); 
%                         subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
%                         subplot(2,3,3), improfile(I_SSD, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('X Profile');
%                         subplot(2,3,6), improfile(I_SSD, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('Y Profile');
%                 else
%                     subjectDouble = str2double(erase(string(subject), 'demd'));
%                     noCoordinates(noCoordCount,1) = subjectDouble;
%                     noCoordCount = noCoordCount+1;
                end
            end    
        end
%     else
%         fprintf('No MLO right folder\n');
%         noProPairMLOR = 1;
    end  
end
