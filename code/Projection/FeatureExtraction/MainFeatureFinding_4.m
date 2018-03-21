%% Create the PCA Space  using the train set
% Then find the eigen-cofficient for train + test + negTrain + negTest

server=0;
imgdim=[333,333]
noOfScales=1;
status= genFeaturePCAEncoding(server,imgdim,noOfScales);
fprintf(status,'\n');
%%




