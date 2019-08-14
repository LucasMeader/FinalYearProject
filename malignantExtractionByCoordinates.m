close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates

malignantMLpatches = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/coordinateBasedMLpatches_benign'));
addedTotal = 1;

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    ccLeftAdded = 0;
    ccRightAdded = 0;
    mloLeftAdded = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates/', subject);
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
                
                newFileName = fullfile(strcat(subject, '_CC', '_Left'));
                
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
                    
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    
                    if tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        dicomInfo = dicominfo(fullImageFilePath);
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
                        
                        originalXCenter = coordxCenter;
                        originalYCenter = coordyCenter;
                        
                        % Adjusting for border to keep extract crops the same size
%                         centerToMaxWidthDif = fullImageWidth-coordxCenter;
%                         if centerToMaxWidthDif < 500
%                             coordxCenter = coordxCenter-(500+centerToMaxWidthDif);
%                         elseif coordxCenter < 500
%                             coordxCenter = coordxCenter+(500-coordxCenter);
%                         end
%                         
%                         % Adjusting for border to keep extract crops the same size
%                         centerToMaxHightDif = fullImageHight-coordyCenter;
%                         if centerToMaxHightDif < 500
%                             coordyCenter = coordyCenter-(500+centerToMaxHightDif);
%                         elseif coordyCenter < 500
%                             coordyCenter = coordyCenter+(500-coordyCenter);
%                         end
                        
                        EX1 = coordxCenter - 500;
                        EX2 = coordxCenter + 500;
                        EY1 = coordyCenter - 500;
                        EY2 = coordyCenter + 500;
                        
                        % Coordinate border for visualisation
                        XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                        YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                        
                        extractTopLeftX = coordxCenter - 113;
                        extractTopLeftY = coordyCenter - 113;
                        
                        sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates/', subject,'/CCpair/left/processedPair/', newFileName));
                        
                        %                         rectangle                top left           width hight
                        extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                        
                        dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                        
                        movefile(sourceFilePath, malignantMLpatches)
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
%                         subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([coordxCenter, coordxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [coordyCenter, coordyCenter]); hold on; plot(originalXCenter,originalYCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; 
%                         subplot(1,2,2), imshow(extractArea, []); title('Extract Patch (Green)');
                        cd ..
                    end
                end
            end
            cd ..
        end
        close all
        
    end
    
    % CC PAIR RIGHT
    if isequal(exist('right', 'dir'),7) % if left folder exists
        cd('right');                      % move into it
        fprintf('CCpair right\n');
        if isequal(exist('processedPair', 'dir'),7)
            %                 fprintf('Processed Pair Exists\n');
            
            newFileName = fullfile(strcat(subject, '_CC', '_Right'));
            
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
                
                tf = strcmp(subjectCoordFullImageNumber, fileName);
                
                if tf == 1
                    fullImageFileName = dcmFiles(currentFile).name;
                    fullImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', fullImageFileName));
                    fullImage = dicomread(fullImageFilePath);
                    dicomInfo = dicominfo(fullImageFilePath);
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
                    
                    originalXCenter = coordxCenter;
                    originalYCenter = coordyCenter;
                    
                    % Adjusting for border to keep extract crops the same size
%                     centerToMaxWidthDif = fullImageWidth-coordxCenter;
%                     if centerToMaxWidthDif < 500
%                         coordxCenter = coordxCenter-(500+centerToMaxWidthDif);
%                     elseif coordxCenter < 500
%                         coordxCenter = coordxCenter+(500-coordxCenter);
%                     end
%                     
%                     % Adjusting for border to keep extract crops the same size
%                     centerToMaxHightDif = fullImageHight-coordyCenter;
%                     if centerToMaxHightDif < 500
%                         coordyCenter = coordyCenter-(500+centerToMaxHightDif);
%                     elseif coordyCenter < 500
%                         coordyCenter = coordyCenter+(500-coordyCenter);
%                     end
                    
                    EX1 = coordxCenter - 500;
                    EX2 = coordxCenter + 500;
                    EY1 = coordyCenter - 500;
                    EY2 = coordyCenter + 500;
                    
                    % Coordinate border for visualisation
                    XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                    YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                    
                    extractTopLeftX = coordxCenter - 113;
                    extractTopLeftY = coordyCenter - 113;
                    
                    sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates/', subject,'/CCpair/right/processedPair/', newFileName));
                    
                    %                         rectangle                top left           width hight
                    extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                    
                    dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                    
                    movefile(sourceFilePath, malignantMLpatches)
                    
%                     figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
%                     subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([coordxCenter, coordxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [coordyCenter, coordyCenter]); hold on; plot(originalXCenter,originalYCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; 
%                     subplot(1,2,2), imshow(extractArea, []); title('Extract Patch (Green)');
                    cd ..
                end
            end
            close all
            cd ..
        end
    end
    cd ..
    
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
                
                newFileName = fullfile(strcat(subject, '_MLO', '_Left'));
                
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
                    
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    
                    if tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        dicomInfo = dicominfo(fullImageFilePath);
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
                        
                        originalXCenter = coordxCenter;
                        originalYCenter = coordyCenter;                        
                        
                        % Adjusting for border to keep extract crops the same size
%                         centerToMaxWidthDif = fullImageWidth-coordxCenter;
%                         if centerToMaxWidthDif < 500
%                             coordxCenter = coordxCenter-(500+centerToMaxWidthDif);
%                         elseif coordxCenter < 500
%                             coordxCenter = coordxCenter+(500-coordxCenter);
%                         end
%                         
%                         % Adjusting for border to keep extract crops the same size
%                         centerToMaxHightDif = fullImageHight-coordyCenter;
%                         if centerToMaxHightDif < 500
%                             coordyCenter = coordyCenter-(500+centerToMaxHightDif);
%                         elseif coordyCenter < 500
%                             coordyCenter = coordyCenter+(500-coordyCenter);
%                         end
                        
                        EX1 = coordxCenter - 500;
                        EX2 = coordxCenter + 500;
                        EY1 = coordyCenter - 500;
                        EY2 = coordyCenter + 500;
                        
                        % Coordinate border for visualisation
                        XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                        YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                        
                        extractTopLeftX = coordxCenter - 113;
                        extractTopLeftY = coordyCenter - 113;
                        
                        sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates/', subject,'/MLOpair/left/processedPair/', newFileName));
                        
                        %                         rectangle                top left           width hight
                        extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                        
                        dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                        
                        movefile(sourceFilePath, malignantMLpatches)
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
%                         subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([coordxCenter, coordxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [coordyCenter, coordyCenter]); hold on; plot(originalXCenter,originalYCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; 
%                         subplot(1,2,2), imshow(extractArea, []); title('Extract Patch (Green)');
                    end
                end
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
                
                newFileName = fullfile(strcat(subject, '_MLO', '_Right'));
                
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
                    
                    tf = strcmp(subjectCoordFullImageNumber, fileName);
                    
                    if tf == 1
                        fullImageFileName = dcmFiles(currentFile).name;
                        fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', fullImageFileName));
                        fullImage = dicomread(fullImageFilePath);
                        dicomInfo = dicominfo(fullImageFilePath);
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
                        
                        originalXCenter = coordxCenter;
                        originalYCenter = coordyCenter;                        
                        
                        % Adjusting for border to keep extract crops the same size
%                         centerToMaxWidthDif = fullImageWidth-coordxCenter;
%                         if centerToMaxWidthDif < 500
%                             coordxCenter = coordxCenter-(500+centerToMaxWidthDif);
%                         elseif coordxCenter < 500
%                             coordxCenter = coordxCenter+(500-coordxCenter);
%                         end
%                         
%                         % Adjusting for border to keep extract crops the same size
%                         centerToMaxHightDif = fullImageHight-coordyCenter;
%                         if centerToMaxHightDif < 500
%                             coordyCenter = coordyCenter-(500+centerToMaxHightDif);
%                         elseif coordyCenter < 500
%                             coordyCenter = coordyCenter+(500-coordyCenter);
%                         end
                        
                        EX1 = coordxCenter - 500;
                        EX2 = coordxCenter + 500;
                        EY1 = coordyCenter - 500;
                        EY2 = coordyCenter + 500;
                        
                        % Coordinate border for visualisation
                        XExtractBorder = [EX1, EX2, EX2, EX1, EX1];
                        YExtractBorder = [EY1, EY1, EY2, EY2, EY1];
                        
                        extractTopLeftX = coordxCenter - 113;
                        extractTopLeftY = coordyCenter - 113;
                        
                        sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/withCoordinates/', subject,'/MLOpair/right/processedPair/', newFileName));
                        
                        %                         rectangle                top left           width hight
                        extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       226 226]);
                        
                        dicomwrite(extractArea, newFileName, dicomInfo, 'CreateMode', 'copy');
                        
                        movefile(sourceFilePath, malignantMLpatches)
                        
%                         figure('Renderer', 'painters', 'Position', [400 100 1500 600]);
%                         subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([coordxCenter, coordxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [coordyCenter, coordyCenter]); hold on; plot(originalXCenter,originalYCenter,'bo'); plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on; 
%                         subplot(1,2,2), imshow(extractArea, []); title('Extract Patch (Green)');
                    end
                    close all
                end
            end
        end
    end
end



