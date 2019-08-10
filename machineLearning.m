clear all


% Load data
imds = imageDatastore('/vol/vssp/ucdatasets/mammo2/TotalRecall/OptimamData/Images/trainingSets', ...
'FileExtensions','.tif', ...
'IncludeSubfolders',true, ...
'LabelSource','foldernames');

% Devide data into training and validation sets
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.7,'randomized');

% Load pre-trained network (AlexNet)
net = alexnet;

%analyzeNetwork(net);

% Image input size 227x227x3
inputSize = net.Layers(1).InputSize;

% Extract all layer but the last three
layersTransfer = net.Layers(1:end-3);

% number of classes. In this case benign and cancerous (2)
numClasses = numel(categories(imdsTrain.Labels));

% Append new layers to the end of AlexNet
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

% Training options
options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',1e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',3, ...
    'Verbose',false, ...
    'Plots','training-progress');

netTransfer = trainNetwork(imdsTrain,layers,options);

