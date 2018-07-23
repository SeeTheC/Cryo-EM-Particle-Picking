%% Create the PCA Space  using the train set
% Then find the eigen-cofficient for train + test + negTrain + negTest

server=2;
%imgdim=[333,333]
%imgdim=[98,98]
%imgdim=[278,278]
%imgdim=[444,444]

% Real Dataset
% EM-10025: imgdim=[216,216]
imgdim=[216,216];
noOfScales=4;
% maxNumberSample used when training set has large number of data point and
% we need only few i.t traing set has 50K points and we want only 2000
% points
maxNumberSample=18000;
status= genFeaturePCAEncoding(server,imgdim,[4,8,12],maxNumberSample);
fprintf(status,'\n');
%%




