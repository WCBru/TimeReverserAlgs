close all; clear;
addpath('../Utils'); addpath('SupportScripts');
width = 0.4;
targetSize = [30, 30]; % size of target beam image
targetImage = zeros([1080, 1920 / 2]); % SLM Resolution

% Create Input Image
inputImage = CreateInputPlane(targetImage);

% Create HG modes
modeNumbers = CreateModeIndices(0, 8);
modes = CreateHGModes(modeNumbers, targetSize, width);

% Calculate coefficients
imageNames = "images/" + (9:-1:-1) + ".png";
targetCoeffs = CalculateImageCoeffs(modes, imageNames, ...
    [size(modes, 1), size(modes, 2)], 0);

% Size of target gauss dots (in pixels)
dotSize = floor(size(inputImage, 1) / (size(modes, 3) * 3)) * [1, 1];

% Gaussian template - take first mode of HG modes created
gaussTemplate  = imresize(modes(:, :, 1), dotSize);
padSize = 2*dotSize(1); % Distance from dot array to discard region

% Create target image
vertStart = floor((size(targetImage, 1) - size(modes, 3) * dotSize(1))/2);
horistart = 25 * dotSize(2);
targetImage = CreateTargetImage(size(targetImage), gaussTemplate, ...
    targetCoeffs, vertStart, horistart, size(modes, 3));
targetImage = complex(targetImage);

% Active space - the area replaced in far field
activeRows = (1:(dotSize(1) * size(modeNumbers, 1) + 2 * padSize)) + vertStart - padSize;
activeCols = (1:(size(targetImage, 2)));
recongs = inputImage(:, :);
q = 0; p = 0.8; counter = 0;

figure(1); subplot(1, 2, 1);
imshow(ComplexImage(inputImage)); title('Input Gaussian');
subplot(1, 2, 2); 
imshow(ComplexImage(targetImage)); title('Target Image');

while q < .9
    recongs = GerchSaxSingle2(recongs, targetImage, ...
        activeRows, activeCols, p); 
    recongs = abs(inputImage) .* exp(1i * angle(recongs));
    % maybe normalise here

    farfield = fftshift(fft2(recongs));
    [q, l] = QuailtyLoss(farfield, targetImage, activeRows, activeCols);
    
    figure(2); subplot(1, 2, 1);
    imshow(ComplexImage(recongs),'InitialMagnification','fit'); 
    title('In-Progress SLM');
    subplot(1, 2, 2);
    imshow(ComplexImage(farfield),'InitialMagnification','fit'); 
    title('In-Progress Far Field');
    counter  = counter + 1;
end

farfield = fftshift(fft2(recongs));
figure(3); subplot(1, 2, 2); 
imshow(ComplexImage(recongs)); title('SLM Image');
imshow(ComplexImage(farfield)); title('Farfield');

function [q, l] = QuailtyLoss(farfield, goal, rows, cols)
    goal = goal / sqrt(sum(sum(goal .*conj(goal))));
    farfield = farfield / sqrt(sum(sum(farfield .*conj(farfield))));
    
    % Extract ROI and normalise
    roi = farfield(rows, cols);
    roi = roi / sqrt(sum(sum(roi .*conj(roi))));
    
    % Calculate quality and loss
    q = abs(sum(sum(conj(roi) .* goal(rows, cols))));
    farfield(rows, cols) = zeros(length(rows), length(cols));
    l = sum(sum(farfield .*conj(farfield)));
end