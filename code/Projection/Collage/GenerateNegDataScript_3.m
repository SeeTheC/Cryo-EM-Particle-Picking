% Generate negative samples from collage
% Negative Samples images means ovelap image
fprintf('Creating NEGATIVE Img for Train and Test +ve Collage Data...\n');
addpath('../DataCorrection/');
%% Init
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end

% --------------------[Config] ------------------------------
% Dataset:1
%basepath=strcat(basepath,'/_data-Y,Z','v.10');
%basepath=strcat(basepath,'/_data-proj-5693','v.30');
%basepath=strcat(basepath,'/Noisy_downscale2');
%basepath=strcat(basepath,'/Noisy_downscale10');
%basepath=strcat(basepath,'/Noisy_downscale20');
%basepath=strcat(basepath,'/Noisy_downscale50');
%basepath=strcat(basepath,'/Noisy_downscale100');
%basepath=strcat(basepath,'/Noisy_downscale200');
%cellH=333; cellW=333; % Per cell one image
%trainPath = strcat(basepath,'/train');
%testPath = strcat(basepath,'/test');

% Dataset:2
basepath=strcat(basepath,'/_data-proj-2211','v.20');
%basepath=strcat(basepath,'/Noisy_downscale2');
%basepath=strcat(basepath,'/Noisy_downscale10');
%basepath=strcat(basepath,'/Noisy_downscale20');
%basepath=strcat(basepath,'/Noisy_downscale50');
%basepath=strcat(basepath,'/Noisy_downscale100');
%basepath=strcat(basepath,'/Noisy_downscale200');
cellH=98; cellW=98; % Per cell one image
trainPath = strcat(basepath,'/train');
testPath = strcat(basepath,'/test');

% Dataset:3
%basepath=strcat(basepath,'/_data-proj-5689','v.20');
%basepath=strcat(basepath,'/Noisy_downscale2');
%basepath=strcat(basepath,'/Noisy_downscale10');
%basepath=strcat(basepath,'/Noisy_downscale20');
%basepath=strcat(basepath,'/Noisy_downscale50');
%basepath=strcat(basepath,'/Noisy_downscale100');
%basepath=strcat(basepath,'/Noisy_downscale200');
%cellH=278; cellW=278; % Per cell one image
%trainPath = strcat(basepath,'/train');
%testPath = strcat(basepath,'/test');

% Dataset:4
%basepath=strcat(basepath,'/_data-proj-5762','v.10');
%basepath=strcat(basepath,'/Noisy_downscale2');
%basepath=strcat(basepath,'/Noisy_downscale10');
%basepath=strcat(basepath,'/Noisy_downscale20');
%basepath=strcat(basepath,'/Noisy_downscale50');
%basepath=strcat(basepath,'/Noisy_downscale100');
%basepath=strcat(basepath,'/Noisy_downscale200');
%cellH=444; cellW=444; % Per cell one image
%trainPath = strcat(basepath,'/train');
%testPath = strcat(basepath,'/test');

gridRow=6; gridCol=6;
% -----------------------------------------------------------



% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
trainCollageDP = strcat(trainPath,'/collage1_6x6');
testCollageDP = strcat(testPath,'/collage1_6x6');


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