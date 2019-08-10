close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates

benignMLpatches = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/benignMousePointExtraction'));
addedTotal = 1;

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 94:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    
    ccLeftAdded = 0;
    ccRightAdded = 0;
    mloLeftAdded = 0;
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates/', subject);
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
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped');
                    
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imrotate(croppedSpotImage, 7, 'bilinear', 'crop');
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    else
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
                
                extractTopLeftX = cropxCenter - 500;
                extractTopLeftY = cropyCenter - 500;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates/', subject,'/CCpair/left/processedPair/', newFileName));
                
                                %                    rectangle         top left           width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       999 999]);
                
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on;
                subplot(1,2,2), imshow(croppedSpotImage, []); title('croppedSpotImage');
                
                [x,y] = ginput(1)
                close all
                topLeftX = x-113;
                topRightY = y-113;
                
                %                    rectangle         top left           width hight
                mousePointExtract = imcrop(fullImage,  [topLeftX topRightY       226 226]);

                dicomwrite(mousePointExtract, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, benignMLpatches)
                
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
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped');
                    
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imrotate(croppedSpotImage, 7, 'bilinear', 'crop');
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    else
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
                
                % Find maximum correspondence in I_NCC image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
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
                
                extractTopLeftX = cropxCenter - 500;
                extractTopLeftY = cropyCenter - 500;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates/', subject,'/CCpair/right/processedPair/', newFileName));
                
                                %                    rectangle         top left           width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       999 999]);
                
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on;
                subplot(1,2,2), imshow(croppedSpotImage, []); title('croppedSpotImage');
                
                [x,y] = ginput(1)
                
                close all
                
                topLeftX = x-113;
                topRightY = y-113;
                
                %                    rectangle         top left           width hight
                mousePointExtract = imcrop(fullImage,  [topLeftX topRightY       226 226]);

                dicomwrite(mousePointExtract, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, benignMLpatches)
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
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped');
                    
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imrotate(croppedSpotImage, 7, 'bilinear', 'crop');
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    else
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
                
                % Find maximum correspondence in I_NCC image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
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
                
                extractTopLeftX = cropxCenter - 500;
                extractTopLeftY = cropyCenter - 500;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates/', subject,'/MLOpair/left/processedPair/', newFileName));
                
                                %                    rectangle         top left           width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       999 999]);
                
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on;
                subplot(1,2,2), imshow(croppedSpotImage, []); title('croppedSpotImage');
                
                [x,y] = ginput(1)
                
                close all
                
                topLeftX = x-113;
                topRightY = y-113;
                
                %                    rectangle         top left           width hight
                mousePointExtract = imcrop(fullImage,  [topLeftX topRightY       226 226]);

                dicomwrite(mousePointExtract, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, benignMLpatches)
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
                
                dcmFiles = dir('*.dcm');
                for currentFile = 1:length(dcmFiles)
                    fileName = dcmFiles(currentFile).name;
                    cropFlag = strfind(fileName, 'cropped');
                    
                    if cropFlag > 0
                        croppedSpotFileName = dcmFiles(currentFile).name;
                        croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair/', croppedSpotFileName));
                        croppedSpotImage = dicomread(croppedSpotImageFilePath);
                        %croppedSpotImage = imrotate(croppedSpotImage, 7, 'bilinear', 'crop');
                        %croppedSpotImage = imcrop(croppedSpotImage, []);
                        [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                        cropFlag = 0;
                    else
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
                
                % Find maximum correspondence in I_NCC image
                [cropyCenter, cropxCenter] = find(I_NCC == max(I_NCC(:)));
                
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
                
                extractTopLeftX = cropxCenter - 500;
                extractTopLeftY = cropyCenter - 500;
                
                sourceFilePath = fullfile(strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Benign/bNoCoordinates/', subject,'/MLOpair/right/processedPair/', newFileName));
                
                                %                    rectangle         top left           width hight
                extractArea = imcrop(fullImage,  [extractTopLeftX extractTopLeftY       999 999]);
                
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(1,2,1), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XExtractBorder, YExtractBorder, 'g-', 'LineWidth', 1); hold on;
                subplot(1,2,2), imshow(croppedSpotImage, []); title('croppedSpotImage');
                
                [x,y] = ginput(1)
                
                close all
                
                topLeftX = x-113;
                topRightY = y-113;
                
                %                    rectangle         top left           width hight
                mousePointExtract = imcrop(fullImage,  [topLeftX topRightY       226 226]);

                dicomwrite(mousePointExtract, newFileName, dicomInfo, 'CreateMode', 'copy');
                
                movefile(sourceFilePath, benignMLpatches)
            end
            close all
        end
    end
end


