close all; clear;
addpath('../Utils'); addpath('SupportScripts');

% Sim constants
numMasks = 7; passes = 7;
slmResolution = [256, 256];
lambda = 1565e-9;
pixelSize = 9.2e-6;
mfdIn = 925e-6;
mfdOut = 400e-6;
planeDist = 25e-3; reflectAngleDeg = 6;
modeNumbers = [0, 3];
%modeNumbers = CreateModeIndices(0, 2);
numModes = size(modeNumbers, 1);

offset = sqrt(1e-9/(prod(slmResolution) * numModes));
kFilter = 1;%0.5*sqrt(2);

% Create parameters for sim from real measurements
[propD, X, Y, beamWaistIn, beamWaistOut] = CreateSimParams(planeDist, ...
    reflectAngleDeg, pixelSize, slmResolution, mfdIn, mfdOut);

% Create propagation function(s)
HFree = GenFreeSpaceTF(slmResolution(2), slmResolution(1), ...
    [max(max(X)), min(min(X))], [max(max(Y)), min(min(Y))], ...
    propD, lambda);
R = sqrt(X.^2 + Y.^2);
HFree(R>=(kFilter*max(max(R)))) = 0;

% Create input
inputImages = CreateDotStrip(slmResolution, beamWaistIn, 1);

% Create output modes
modes = CreateHGModes(modeNumbers, slmResolution, beamWaistOut);

% Per set calculations
MASKS = zeros(numModes, numMasks, slmResolution(1), slmResolution(2));
insertionLosses = zeros(1, numModes);

% Complete each individually
outputs = zeros(size(modes));
for s = 1:numModes
    currMasks = MPLC_Generate(numMasks, passes, inputImages, ...
        modes(:, :, s), HFree, offset);
    
    output = inputImages(:, :);
    for m = 1:numMasks
        output = ApplyMaskToImages(output, currMasks(:, :, m), HFree, 1, 1);
        MASKS(s, m, :, :) = exp(1i * currMasks(:, :, m));
    end
    outputs(:, :, s) = output;
    
    [~, insert, ~] = LossCalculation(modes(:, :, s), output);
    insertionLosses(s) = insert;
    imshow(ComplexImage(output));
end

CONJMASKS = conj(MASKS);

params = struct();
params.numMasks = numMasks; params.passes = passes;
params.slmResolution = slmResolution;
params.lambda = lambda;
params.pixelSize = pixelSize;
params.mfdIn = mfdIn;
params.mfdOut = mfdOut;
params.planeDist = planeDist; 
params.reflectAngleDeg = reflectAngleDeg;

params.modeNumbers = modeNumbers;
params.numModes = numModes;

params.offset = offset;
params.kFilter = kFilter;