%% Init
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/';  
end
% SaveDir: NOTE. CHANEGE DIR Version EVERY TIME YOU GENERATE
%basepath=strcat(basepath,'/_data-Y,Z','v.10');
%basepath=strcat(basepath,'/_data-Y,Z','v.10','/Noisy_downscale500');
%basepath=strcat(basepath,'/_data-proj-2211','v.20','/Noisy_downscale20');
basepath=strcat(basepath,'/_data-proj-5689','v.20','/Noisy_downscale500');

collage='1';
trainPath=strcat(basepath,'/train','/collage1_6x6');
testPath=strcat(basepath,'/test','/collage1_6x6');

testCollageRawPath= strcat(testPath,'/processed_img/')
%testCollageRawPath= strcat(testPath,'/processed_img/ramdomForest');
testCollageRawPath= strcat(testCollageRawPath,'/',collage);
testCollageRawPath=strcat(testCollageRawPath,'/model_1-2-4/model-1');
name=strcat(testCollageRawPath,'/',collage,'.mat');
struct=load(name);
scoreCollage=struct.outImg;

originalCollageName=strcat(testPath,'/raw_img/',collage,'.mat');
struct=load(originalCollageName);
collage=struct.img;
[H,W]=size(collage);

cellH=278; cellW=278;
%% Finding  location using maxmial suppression

boxSize=[cellH,cellW];
supressBoxSize=[170,170];
probThershold=0.5;
[cX,cY]=findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,1000);
noOfRect=size(cX,1);
fprintf('noOfRect:%d .Done...\n',noOfRect);
%% Drawing box
fprintf('Drawing Box...\n');
img=imresize(double(collage),1);
img=img/max(img(:));
lineWidth=4;predictColor='red';
%mark center
% predicted center    
for r= 1:noOfRect
    cx=cX(r);cy=cY(r);
    markSize=10;
    img=insertMarker(img,[cy,cx],'x','color',predictColor,'size',markSize);    
    for w=1:lineWidth
        img=insertMarker(img,[cy-w,cx],'x','color',predictColor,'size',markSize); 
        img=insertMarker(img,[cy,cx-w],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy+w,cx],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy,cx+w],'x','color',predictColor,'size',markSize);    

    end
end
fprintf('Done.\n');
% Drawing True Center
fprintf('Drawing True Center...\n');
img1=img;
halfPatchH=cellH/2;halfPatchW=cellW/2;  
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
hInc=cellH-1;wInc=cellW-1;
lineWidth=4;predictColor='green';
for r= hStartIdx:hInc:hEndIdx
    for c=wStartIdx:wInc:wEndIdx        
    cx=r;cy=c;
    markSize=10;
    img=insertMarker(img1,[cy,cx],'x','color',predictColor,'size',markSize);    
        for w=1:lineWidth
            img1=insertMarker(img1,[cy-w,cx],'x','color',predictColor,'size',markSize); 
            img1=insertMarker(img1,[cy,cx-w],'x','color',predictColor,'size',markSize);    
            img1=insertMarker(img1,[cy+w,cx],'x','color',predictColor,'size',markSize);    
            img1=insertMarker(img1,[cy,cx+w],'x','color',predictColor,'size',markSize);    

        end
    end
end
fprintf('Done.\n');
% Show result
figure,
imshow(img1,[]),impixelinfo;
title('\fontsize{10}{\color{magenta}EM-5689. Green is true location. Red is predicted.}');
%% Save Center mark
imwrite(img1,'center_mark.png');
%% Draw rectangle
fprintf('Drawing rectangle...\n');
fh = figure;
imshow(img1);
hold on;
for r= 1:noOfRect
    cx=cX(r);cy=cY(r);
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
    
end
%% Save/show
%frm = getframe( fh ); %// get the image+rectangle
%imwrite(frm.cdata,'boxImage.png');
%hold off;
figure,
imshow(img1);
fprintf('Done.\n');
%%