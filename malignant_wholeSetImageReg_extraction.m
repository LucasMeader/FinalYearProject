close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

malignantMLpatches = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/b227patches'));
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
            fprintf('CCpair left\n'); 
            if isequal(exist('processedPair', 'dir'),7)
                %                 fprintf('Processed Pair Exists\n');
                
                newFileName = fullfile(strcat(subject, '_CC_Left.dcm'));
                
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
                    cropFlag = strfind(fileName, 'cropped');
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    elseif tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        dicomInfo = dicominfo(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                
                % Calculate SSD and NCC between Template and Image
                [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                
                % Find maximum correspondence in I_NCC image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
                % Adjusting for border to keep extract crops the same size
%                 centerToMaxWidthDif = fullImageWidth-cropxCenter;
%                 if centerToMaxWidthDif < 500
%                 cropxCenter = cropxCenter-(500+centerToMaxWidthDif);
%                 elseif cropxCenter < 500
%                     cropxCenter = cropxCenter+(500-cropxCenter);
%                 end
%                 
%                 % Adjusting for border to keep extract crops the same size
%                 centerToMaxHightDif = fullImageHight-cropyCenter;
%                 if centerToMaxHightDif < 500
%                 cropyCenter = cropyCenter-(500+centerToMaxHightDif);
%                 elseif cropyCenter < 500
%                     cropyCenter = cropyCenter+(500-cropyCenter);
%                 end
                
                CX1 = cropxCenter - cropImageWidth/2;
                CX2 = cropxCenter + cropImageWidth/2;
                CY1 = cropyCenter - cropImageHight/2;
                CY2 = cropyCenter + cropImageHight/2;
                
                % Coordinate border for visualisation
                XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                
                EX1 = cropxCenter - 500;
                EX2 = cropxCenter + 500;
                EY1 = cropyCenter - 500;
                EY2 = cropyCenter + 500;
                
                % Coordinate border for visualisation
                XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                
                extractTopLeftX = cropxCenter - 113;
                extractTopLeftY = cropyCenter - 113;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject,'/CCpair/left/processedPair/', newFileName));
                
                %                         rectangle                top left           width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);

                extractArea(:,:,[1 1 1]);
                
                dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, malignantMLpatches)
                
                figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
                subplot(2,3,1), imshow(I_NCC, []); title('NCC Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); 
                colorbar;
                subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1);
                subplot(2,3,2), imshow(extractArea, []); title('Extract Patch (Green)');
                subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
                subplot(2,3,3), improfile(I_NCC, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
                subplot(2,3,6), improfile(I_NCC, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
                cd ..
            end
            close all
            cd ..
        end
        
        % CC PAIR RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists
            cd('right');                      % move into it
            fprintf('CCpair right\n'); 
            if isequal(exist('processedPair', 'dir'),7)
                %                 fprintf('Processed Pair Exists\n');
                newFileName = fullfile(strcat(subject, '_CC_Right.dcm'));
                
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
                    cropFlag = strfind(fileName, 'cropped');
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
                        dicomInfo = dicominfo(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                
                % Calculate SSD and NCC between Template and Image
                [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                
                % Find maximum correspondence in I_SDD image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
%                 % Adjusting for border to keep extract crops the same size
%                 centerToMaxWidthDif = fullImageWidth-cropxCenter;
%                 if centerToMaxWidthDif < 500
%                     cropxCenter = cropxCenter-(500+centerToMaxWidthDif);
%                 elseif cropxCenter < 500
%                     cropxCenter = cropxCenter+(500-cropxCenter);
%                 end
%                 
%                 % Adjusting for border to keep extract crops the same size
%                 centerToMaxHightDif = fullImageHight-cropyCenter;
%                 if centerToMaxHightDif < 500
%                     cropyCenter = cropyCenter-(500+centerToMaxHightDif);
%                 elseif cropyCenter < 500
%                     cropyCenter = cropyCenter+(500-cropyCenter);
%                 end
                
                CX1 = cropxCenter - cropImageWidth/2;
                CX2 = cropxCenter + cropImageWidth/2;
                CY1 = cropyCenter - cropImageHight/2;
                CY2 = cropyCenter + cropImageHight/2;
                
                % Coordinate border for visualisation
                XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                
                EX1 = cropxCenter - 500;
                EX2 = cropxCenter + 500;
                EY1 = cropyCenter - 500;
                EY2 = cropyCenter + 500;
                
                % Coordinate border for visualisation
                XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                
                extractTopLeftX = cropxCenter - 113;
                extractTopLeftY = cropyCenter - 113;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject,'/CCpair/right/processedPair/', newFileName));
                
                %                         rectangle                top left            width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                
                extractArea(:,:,[1 1 1]);
                
                dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, malignantMLpatches)
                
                figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
                subplot(2,3,1), imshow(I_NCC, []); title('NCC Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); 
                colorbar;
                subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
                subplot(2,3,2), imshow(extractArea, []); title('Extract Patch (Green)');
                subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
                subplot(2,3,3), improfile(I_NCC, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
                subplot(2,3,6), improfile(I_NCC, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
                
                cd ..
            end
            close all
            cd ..
        end
        cd ..
    end
    % MLO
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        %fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left');                      % move into it
            fprintf('MLOpair left\n'); 
            if isequal(exist('processedPair', 'dir'),7)
                %                 fprintf('Processed Pair Exists\n');
                newFileName = fullfile(strcat(subject, '_MLO_Left.dcm'));
                
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
                    cropFlag = strfind(fileName, 'cropped');
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
                        dicomInfo = dicominfo(fullImageFilePath);
                        % Obtaining image size data
                        [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                    end
                end
                % Calculate SSD and NCC between Template and Image
                [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                
                % Find maximum correspondence in I_SDD image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
                % Adjusting for border to keep extract crops the same size
%                 centerToMaxWidthDif = fullImageWidth-cropxCenter;
%                 if centerToMaxWidthDif < 500
%                     cropxCenter = cropxCenter-(500+centerToMaxWidthDif);
%                 elseif cropxCenter < 500
%                     cropxCenter = cropxCenter+(500-cropxCenter);
%                 end
%                 
%                 % Adjusting for border to keep extract crops the same size
%                 centerToMaxHightDif = fullImageHight-cropyCenter;
%                 if centerToMaxHightDif < 500
%                     cropyCenter = cropyCenter-(500+centerToMaxHightDif);
%                 elseif cropyCenter < 500
%                     cropyCenter = cropyCenter+(500-cropyCenter);
%                 end
                
                CX1 = cropxCenter - cropImageWidth/2;
                CX2 = cropxCenter + cropImageWidth/2;
                CY1 = cropyCenter - cropImageHight/2;
                CY2 = cropyCenter + cropImageHight/2;
                
                % Coordinate border for visualisation
                XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                
                EX1 = cropxCenter - 500;
                EX2 = cropxCenter + 500;
                EY1 = cropyCenter - 500;
                EY2 = cropyCenter + 500;
                
                % Coordinate border for visualisation
                XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                
                extractTopLeftX = cropxCenter - 113;
                extractTopLeftY = cropyCenter - 113;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject,'/MLOpair/left/processedPair/', newFileName));
                
                %                         rectangle                top left            width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                
                extractArea(:,:,[1 1 1]);
                
                dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, malignantMLpatches)
                
                figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
                subplot(2,3,1), imshow(I_NCC, []); title('NCC Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); 
                colorbar;
                subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
                subplot(2,3,2), imshow(extractArea, []); title('Extract Patch (Green)');
                subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
                subplot(2,3,3), improfile(I_NCC, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
                subplot(2,3,6), improfile(I_NCC, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
                
                cd ..
            end
            close all
            cd ..
        end
        % MLO RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists
            cd('right');                      % move into it
            fprintf('MLOpair right\n'); 
            if isequal(exist('processedPair', 'dir'),7)
                %                 fprintf('Processed Pair Exists\n');
                newFileName = fullfile(strcat(subject, '_MLO_Right.dcm'));
                
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
                cropFlag = strfind(fileName, 'cropped');
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
                    dicomInfo = dicominfo(fullImageFilePath);
                    % Obtaining image size data
                    [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                end
            end
                % Calculate SSD and NCC between Template and Image
                [I_SSD, I_NCC] = template_matching(croppedSpotImage,fullImage);
                
                % Find maximum correspondence in I_SDD image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
                % Adjusting for border to keep extract crops the same size
%                 centerToMaxWidthDif = fullImageWidth-cropxCenter;
%                 if centerToMaxWidthDif < 500
%                     cropxCenter = cropxCenter-(500+centerToMaxWidthDif);
%                 elseif cropxCenter < 500
%                     cropxCenter = cropxCenter+(500-cropxCenter);
%                 end
%                 
%                 % Adjusting for border to keep extract crops the same size
%                 centerToMaxHightDif = fullImageHight-cropyCenter;
%                 if centerToMaxHightDif < 500
%                     cropyCenter = cropyCenter-(500+centerToMaxHightDif);
%                 elseif cropyCenter < 500
%                     cropyCenter = cropyCenter+(500-cropyCenter);
%                 end
                
                CX1 = cropxCenter - cropImageWidth/2;
                CX2 = cropxCenter + cropImageWidth/2;
                CY1 = cropyCenter - cropImageHight/2;
                CY2 = cropyCenter + cropImageHight/2;
                
                % Coordinate border for visualisation
                XCropBorder = [CX1, CX2, CX2, CX1, CX1];
                YCropBorder = [CY1, CY1, CY2, CY2, CY1];
                
                EX1 = cropxCenter - 500;
                EX2 = cropxCenter + 500;
                EY1 = cropyCenter - 500;
                EY2 = cropyCenter + 500;
                
                % Coordinate border for visualisation
                XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                
                extractTopLeftX = cropxCenter - 113;
                extractTopLeftY = cropyCenter - 113;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject, '/MLOpair/right/processedPair/', newFileName));
                
                %                         rectangle                top left            width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                
                extractArea(:,:,[1 1 1]);
                
                dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, malignantMLpatches)
                
                figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
                subplot(2,3,1), imshow(I_NCC, []); title('NCC Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); 
                colorbar;
                subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(cropxCenter,cropyCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
                subplot(2,3,2), imshow(extractArea, []); title('Extract Patch (Green)');
                subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
                subplot(2,3,3), improfile(I_NCC, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
                subplot(2,3,6), improfile(I_NCC, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
            end
            close all
        end
    end
end


