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
trainPath=strcat(basepath,'/train','/collage1_6x6');
testPath=strcat(basepath,'/test','/collage1_6x6');

testCollageRawPath= strcat(testPath,'/processed_img/',collage,'/raw_img');
name=strcat(testCollageRawPath,'/',collage,'.mat');
struct=load(name);
scoreCollage=struct.img;

originalCollageName=strcat(testPath,'/raw_img/',collage,'.mat');
struct=load(originalCollageName);
collage=struct.img;
[H,W]=size(collage);

cellH=333; cellW=333;
%% Finding  location using maxmial suppression

boxSize=[cellH,cellW];
supressBoxSize=[150,150];
probThershold=0.9;
[cX,cY]=findBoxLocation(scoreCollage,boxSize,probThershold,supressBoxSize,1000);
noOfRect=size(cX,1);
fprintf('Done...\n');
%% Drawing box
img=imresize(double(collage),1);
img=img/max(img(:));
lineWidth=3;predictColor='red';
%mark center
% predicted center    
for r= 1:noOfRect
    cx=cX(r);cy=cY(r);
    img=insertMarker(img,[cy,cx],'x','color',predictColor,'size',20);    
    for w=1:lineWidth
        img=insertMarker(img,[cy-w,cx],'x','color',predictColor,'size',20); 
        img=insertMarker(img,[cy,cx-w],'x','color',predictColor,'size',20);    
        img=insertMarker(img,[cy+w,cx],'x','color',predictColor,'size',20);    
        img=insertMarker(img,[cy,cx+w],'x','color',predictColor,'size',20);    

    end
end

%% Drawing True Center
img1=img;
halfPatchH=cellH/2;halfPatchW=cellW/2;  
hStartIdx=ceil(halfPatchH);hEndIdx=H-floor(halfPatchH);
wStartIdx=ceil(halfPatchW);wEndIdx=W-floor(halfPatchW);
hInc=cellH-1;wInc=cellW-1;
lineWidth=3;predictColor='green';
for r= hStartIdx:hInc:hEndIdx
    for c=wStartIdx:wInc:wEndIdx        
    cx=r;cy=c;
    img=insertMarker(img1,[cy,cx],'x','color',predictColor,'size',20);    
        for w=1:lineWidth
            img1=insertMarker(img1,[cy-w,cx],'x','color',predictColor,'size',20); 
            img1=insertMarker(img1,[cy,cx-w],'x','color',predictColor,'size',20);    
            img1=insertMarker(img1,[cy+w,cx],'x','color',predictColor,'size',20);    
            img1=insertMarker(img1,[cy,cx+w],'x','color',predictColor,'size',20);    

        end
    end
end
%% Save Center mark
imwrite(img1,'center_mark.png');
%% Draw rectangle
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
frm = getframe( fh ); %// get the image+rectangle
imwrite(frm.cdata,'boxImage.png');
hold off;
%%