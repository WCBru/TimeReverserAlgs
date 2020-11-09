function [dist, Xm, Ym, waistInNormalised, waistOutNormalised] = ...
    CreateSimParams(planeDist, reflectDeg, pixelSize, res, mfdIn, mfdOut)
    % dist: distance for free=space propagation
    % Xm, Ym: X and Y coordinates in metres
    % waistInNormalised: waist of input beam, normalised for [-1, 1] coords
    % waistOutNormalised: waist of output beam, normalised for [-1, 1] coords
    dist = planeDist / cos(deg2rad(reflectDeg));
    
    % X: cols, Y: rows
    % [1, 2, 3, 4] => [-2, -1, 1, 2]
    % [1, 2, 3] => [-1, 0, 1]
    X = ((1:res(2)) - ceil(res(2)/2)) * pixelSize;
    Y = ((1:res(1)) - ceil(res(1)/2)) * pixelSize;    
    
    [Xm, Ym] = meshgrid(X, Y);
    
    % Calculate normalised waists. Assumes square pixels, and takes the
    % larger res. dim, so beam will fit on output
    maxSize = max(res);
    waistInNormalised = mfdIn / (pixelSize * maxSize);
    waistOutNormalised = mfdOut / (pixelSize * maxSize);
end