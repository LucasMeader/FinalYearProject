close all
clear all

cd /vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful

wrongType = zeros(1000,1);

D = dir;
D = D(~ismember({D.name}, {'.', '..'}));
for k = 1:numel(D)                                               %1:122727
    subject = D(k).name
    dir(subject);
    subjectDouble = str2double(erase(string(subject), 'demd'));
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
    
    infoFileName = strcat('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/Malignant/bUseful/', subject);
    cd(infoFileName)
    % CC
    if isequal(exist('CCpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('CCpair exists\n');         % Comment to consel
        cd('CCpair')                        % move into CCpair folder
        % CC PAIR LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left')                      % move into it
            fprintf('left CC folder exists\n');
            if isequal(exist('smallCroppedProSpotImage', 'dir'),7)
                cd('smallCroppedProSpotImage');
                a = dir('*.dcm');
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/left', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                end
                cd ..
            else
                cropMovedCCL = 1;
            end
            cd ..
        end
    else
        fprintf('No CC left folder\n');
    end
    
    % CC PAIR RIGHT
    if isequal(exist('right', 'dir'),7) % if left folder exists
        cd('right')                      % move into it
        fprintf('right CC folder exists\n');
        if isequal(exist('smallCroppedProSpotImage', 'dir'),7)
            cd('smallCroppedProSpotImage');
            a = dir('*.dcm');
            
            %numberOfDCMInFolder = numel(a);
            for file = 1:min(2, length(a))
                % Moving the processed cropped image to processedPair
                % folder
                imageFilePath = string(a(file).name);
                processedPairLocation = fullfile(strcat(infoFileName, '/CCpair', '/right', '/processedPair'));
                copyfile(imageFilePath, processedPairLocation);
            end
            cd ..
        else
            cropMovedCCR = 1;
        end
        cd ..
    else
        fprintf('No CC right folder\n')
        noProPairCCR = 1;
    end
    cd ..
    
    % MLO
    if isequal(exist('MLOpair', 'dir'),7) % 7 means its a folder and exists
        fprintf('MLOpair exists\n');
        cd('MLOpair')
        % MLO LEFT
        if isequal(exist('left', 'dir'),7) % if left folder exists
            cd('left')                      % move into it
            fprintf('left MLO folder exists\n');
            if isequal(exist('smallCroppedProSpotImage', 'dir'),7)
                cd('smallCroppedProSpotImage');
                a = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/left', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                end
                cd ..
            else
                cropMovedMLOL = 1;
            end
            cd ..
        else
            fprintf('No MLO left folder\n');
            noProPairMLOL = 1;
        end
        % MLO RIGHT
        if isequal(exist('right', 'dir'),7) % if left folder exists
            cd('right')                      % move into it
            fprintf('left MLO folder exists\n');
            if isequal(exist('smallCroppedProSpotImage', 'dir'),7)
                cd('smallCroppedProSpotImage');
                a = dir('*.dcm');
                
                %numberOfDCMInFolder = numel(a);
                for file = 1:min(2, length(a))
                    % Moving the processed cropped image to processedPair
                    % folder
                    imageFilePath = string(a(file).name);
                    processedPairLocation = fullfile(strcat(infoFileName, '/MLOpair', '/right', '/processedPair'));
                    copyfile(imageFilePath, processedPairLocation);
                end
                cd ..
            else
                cropMovedMLOR = 1;
            end
            
        end
    end
    if cropMovedCCL == 1 & cropMovedCCR == 1 & cropMovedMLOL == 1 & cropMovedMLOR == 1
        wrongType(k,1) = subjectDouble;
    end
end