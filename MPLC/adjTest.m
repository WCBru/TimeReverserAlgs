close all; clear;
addpath('../Utils'); addpath('SupportScripts');

% Sim constants
numMasks = 7; passes = 10;
slmResolution = [256, 256];
lambda = 1565e-9;
pixelSize = 9.2e-6;
mfdIn = 200e-6;
mfdOut = 600e-6;
planeDist = 25e-3; reflectAngleDeg = 6;
modeNumbers = [0,2;0,3];
%modeNumbers = CreateModeIndices(3, 4);
numModes = size(modeNumbers, 1);

offset = sqrt(1e-9/(prod(slmResolution) * numModes));

% Create parameters for sim from real measurements
[propD, X, Y, beamWaistIn, beamWaistOut] = CreateSimParams(planeDist, ...
    reflectAngleDeg, pixelSize, slmResolution, mfdIn, mfdOut);

% Create propagation function(s)
HFree = GenFreeSpaceTF(slmResolution(2), slmResolution(1), ...
    [max(max(X)), min(min(X))], [max(max(Y)), min(min(Y))], ...
    propD, lambda);

% Create input
inputImages = CreateDotStrip(slmResolution, beamWaistIn, numModes);

% Create output modes
modes = CreateHGModes(modeNumbers, slmResolution, beamWaistOut);

% Per set calculations

% Complete each individually
mdls = zeros(passes, 1);
inserts = zeros(passes, 1);
currMasks = zeros(size(modes, 1), size(modes, 2), numMasks);
for s = 1:passes
    currMasks = MPLC_Generate(numMasks, 1, inputImages, ...
        modes, HFree, offset, currMasks);
    
    output = inputImages(:, :, :);
    for m = 1:numMasks
        output = ApplyMaskToImages(output, currMasks(:, :, m), HFree, 1, 1);
    end
    
    [mdl, insert, ~] = LossCalculation(modes, output);
    mdls(s) = mdl; inserts(s) = insert;
end

figure;
for i = 1:7
subplot(1, 7, i);
imshow(ComplexImage(exp(1i * currMasks(:, :, i))));
end

figure;
plot(mdls); hold on; plot(inserts);
xlabel("Passes"); ylabel("Loss (dB)");
legend(["MDL", "IL"]);
