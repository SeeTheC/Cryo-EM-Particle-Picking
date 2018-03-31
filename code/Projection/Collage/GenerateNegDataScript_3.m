% Generate negative samples from collage
% Negative Samples images means ovelap image
fprintf('Creating NEGATIVE Img for Train and Test +ve Collage Data...\n');
addpath('../DataCorrection/');
%% Init

if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

% --------------------[Config] ------------------------------
% Dataset:1
basepath=strcat(basepath,'/_data-Y,Z','v.10');
cellH=333; cellW=333; % Per cell one image
%trainPath = strcat(basepath,'/train');
%testPath = strcat(basepath,'/test');
trainPath = strcat(basepath,'/Noisy_downscale2','/train');
testPath = strcat(basepath,'/Noisy_downscale2','/test');

% Dataset:2
%basepath=strcat(basepath,'/_data-proj-2211','v.10');
%cellH=178; cellW=178; % Per cell one image
%trainPath = strcat(basepath,'/train');
%testPath = strcat(basepath,'/test');

gridRow=6; gridCol=6;
% -----------------------------------------------------------


% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
trainCollageDP = strcat(trainPath,'/collage1_10x10');
testCollageDP = strcat(testPath,'/collage1_10x10');

collageDirPath{1,1}=trainPath;
collageDirPath{1,2}=strcat(trainCollageDP,'/raw_img');
collageDirPath{2,1}=testPath;
collageDirPath{2,2}=strcat(testCollageDP,'/raw_img');

%  # collage in the specified folder
negImgPerCollage=10;
%% Generate
for i=1:size(collageDirPath,1)    
    outputStatus  = genNegImgFromCollage(collageDirPath{i,2}, ...
                                         [cellH,cellW],...
                                         [gridRow,gridCol],...                                       
                                         negImgPerCollage,...
                                         collageDirPath{i,1});
    disp(outputStatus);
end
fprintf('Completed ... \n');
%%