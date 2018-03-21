%% Merge the different segment of collage
%% Init
server = 0
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end
% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
basepath=strcat(basepath,'/_data-Y,Z','v.10');

collage='1';
trainPath=strcat(basepath,'/train');
testPath=strcat(basepath,'/test');

testCollageRawPath= strcat(testPath,'/collage1_6x6','/processed_img/',collage,'/raw_img');
saveTestCollagePath= strcat(testPath,'/collage1_6x6','/processed_img/',collage);

%% Merge
cellH=333; cellW=333;
gridRow=6; gridCol=6;
H=cellH*gridRow; W=cellW*gridCol;
thread=10; 
outImg=zeros(H,W);
threadImgHeight= floor(H/thread);
halfPatchH=cellH/2;
for i=1:thread
    offset=(i-1)*threadImgHeight+1;
    x1=offset-floor(halfPatchH);
    x2=offset+threadImgHeight-1+floor(halfPatchH);
    if x1 <1
        x1=1;
    end
    if x2 > H
        x2=H;
    end    
    name=strcat(testCollageRawPath,'/',collage,'_',num2str(i),'.mat');
    struct=load(name);
    img=struct.img;
    outImg(x1:x2,:)=outImg(x1:x2,:)+img;
end
img=outImg;
%% Save
figure
imshow(img,[]),colormap(jet),colorbar
title('\fontsize{10}{\color{magenta} Probability Map}');

%%
imwrite(img,strcat(saveTestCollagePath,'/img/',collage,'.jpg'));
save(strcat(saveTestCollagePath,'/raw_img/',collage,'.mat'),'img');