close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

thetaArrayRads = zeros(618,3);
thetaArrayDegs = zeros(618,3);
distanceArray = zeros(618,3);
noCoordinates = zeros(618,2);
addedTotal = 1;
noCoordCount = 1;

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
k = 1:94
subject = D(k).name;

ccLeftAdded = 0;
ccRightAdded = 0;
mloLeftAdded = 0;


infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject);
cd(infoFileName)

if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
    
    cd('MLOpair')                        % move into CCpair folder
    
    if isequal(exist('left', 'dir'),7) % if left folder exists
        cd('left')                      % move into it
        
        if isequal(exist('processedPair', 'dir'),7)
            fprintf('Processed Pair Exists\n');
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
                cropFlag = strfind(fileName, 'smallCropped.');
                tf = strcmp(subjectCoordFullImageNumber, fileName);
                if cropFlag > 0
                    croppedSpotFileName = dcmFiles(currentFile).name;
                    croppedSpotImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', croppedSpotFileName));
                    croppedSpotImage = dicomread(croppedSpotImageFilePath);
                    %croppedSpotImage = imcrop(croppedSpotImage, []);
                    [cropImageHight, cropImageWidth, cropImageDepth] = size(croppedSpotImage);
                elseif tf == 1
                    fullImageFileName = dcmFiles(currentFile).name;
                    fullImageFilePath = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair/', fullImageFileName));
                    fullImage = dicomread(fullImageFilePath);
                    % Obtaining image size data
                    [fullImageHight, fullImageWidth, fullImageDepth] = size(fullImage);
                end
            end
            jsonFiles = dir('*.json');
            for currentFile = 1:size(jsonFiles)
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
                    
                    for degree = 0

                        rotatedCroppedSpotImage = imrotate(croppedSpotImage, degree, 'bilinear', 'crop');
                        imshow(rotatedCroppedSpotImage, []);
                        % Calculate SSD and NCC between Template and Image
                        [I_SSD, I_NCC] = template_matching(rotatedCroppedSpotImage,fullImage);

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

                        twoPI = 6.2831853071795865;
                        rad2deg = 57.2957795130823209;
                        theta = atan(deltaY/deltaX);
                        if theta < 0.0
                            theta = theta+twoPI ;
                        end
                        thetaInDegrees = rad2deg*theta;

                        %Add to arrays
                        subjectDouble = str2double(erase(string(subject), 'demd'));
                        thetaArrayRads(addedTotal,2) = subjectDouble;
                        thetaArrayRads(addedTotal,1) = theta;
                        thetaArrayRads(addedTotal,3) = degree;
                        thetaArrayDegs(addedTotal,2) = subjectDouble;
                        thetaArrayDegs(addedTotal,1) = thetaInDegrees;
                        thetaArrayDegs(addedTotal,3) = degree;
                        distanceArray(addedTotal,2) = subjectDouble;
                        distanceArray(addedTotal,1) = distanceBetweenCentres;
                        distanceArray(addedTotal,3) = degree;
                        addedTotal = addedTotal+1;
                    end
                    
                    figure('Renderer', 'painters', 'Position', [400 100 1700 800]);
                    subplot(2,3,1), imshow(I_NCC, []); title('SSD Matching'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
                    colorbar;
                    subplot(2,3,4), imshow(fullImage, []); title('Full Processed Image'); hold on; line([cropxCenter, cropxCenter], [fullImageHight, 0]); hold on; line([0, fullImageWidth], [cropyCenter, cropyCenter]); hold on; plot(XFullBorder, YFullBorder, 'g-', 'LineWidth', 1); hold on; plot(XCropBorder, YCropBorder, 'b-', 'LineWidth', 1)
                    subplot(2,3,2), imshow(fullViewCoordArea, []); title('Coordinate Patch (Green)');
                    subplot(2,3,5), imshow(croppedSpotImage, []); title('Spot Patch (Blue)');
                    subplot(2,3,3), improfile(I_NCC, [cropxCenter, cropxCenter], [fullImageHight, 0]); title('Y Profile');
                    subplot(2,3,6), improfile(I_NCC, [0, fullImageWidth], [cropyCenter, cropyCenter]); title('X Profile');
                else
                    fprintf('No coordinates');
                    subjectDouble = str2double(erase(string(subject), 'demd'));
                    noCoordinates(noCoordCount,1) = subjectDouble;
                    noCoordCount = noCoordCount+1;
                end
            end
        end
    end
end
