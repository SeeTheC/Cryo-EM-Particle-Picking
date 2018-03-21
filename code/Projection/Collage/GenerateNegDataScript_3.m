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

trainPath=strcat(basepath,'/_data-Y,Z','v.10','/train');
testPath=strcat(basepath,'/_data-Y,Z','v.10','/test');

% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
trainCollageDP = strcat(trainPath,'/collage1_10x10');
testCollageDP = strcat(testPath,'/collage1_10x10');

collageDirPath{1,1}=trainPath;
collageDirPath{1,2}=strcat(trainCollageDP,'/raw_img');
collageDirPath{2,1}=testPath;
collageDirPath{2,2}=strcat(testCollageDP,'/raw_img');


% Per cell one image
cellH=333; cellW=333;
gridRow=10; gridCol=10;

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