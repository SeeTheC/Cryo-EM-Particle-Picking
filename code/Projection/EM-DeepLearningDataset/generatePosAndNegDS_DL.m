function [status,finaltbl] = generatePosAndNegDS_DL(mgPath,patchSize,coordMetadataPath,testPercent,basepath)
    status='Incomplete';
    %% Init
    % mgMaxHW : Will be used for partitioning the large MicroGraph into
    % submicrograph.
    mgMaxHW=1000;
    
    timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
    
    savepath=strcat(basepath,'/dl_projection_mghw_',mgMaxHW,'_tr_',timestamp);
    saveTrainPath=strcat(savepath,'/Train');
    saveTrainPathImg=strcat(saveTrainPath,'/img');
    trainBBoxPath=strcat(saveTrainPathImg,'/train_bbox.csv');
    
    saveTestPath=strcat(savepath,'/Test');
    saveTestPathImg=strcat(saveTestPath,'/img');
    testBBoxPath=strcat(saveTestPath,'/test_bbox.csv');
        
    mkdir(savepath);
    mkdir(saveTrainPath);mkdir(saveTrainPathImg);
    mkdir(saveTestPath);mkdir(saveTestPathImg);
    
    fprintf('Init Done.\n');
    %% Process
    fileNameList=getDirFilesName(mgPath);
    noOfMg=size(fileNameList,2);
    nTrain=ceil((1-testPercent/100)*noOfMg);
    nTest= noOfMg-nTrain;
    fprintf('No. of Train MG: %d \n No. of Test MG:%d\n',nTrain,nTest);
    totalPosParticleCount=0;
    totalNegParticleCount=0;
    finaltbl = cell2table(cell(0,2));
    for m=1:1%noOfMg
        mgName=fileNameList{m};
        mgFile=strcat(mgPath,'/',mgName);
        fprintf('Processing mg #%d:%s\n',m,mgName);        
        [micrograph,~,~,~,~]=ReadMRC(mgFile);
        [coordTable,keyword] = getRelionCoordinate(mgName,coordMetadataPath);
        
        %divideAndSaveMG(micrograph,mgMaxHW,saveTrainPathImg,keyword)        
        [particleTbl]=convertCoordinatIntoBBox(coordTable,patchSize,size(micrograph),mgMaxHW,keyword);
        finaltbl=[finaltbl;particleTbl];
        %noOfParticle=size(coordTable,1)
     end

    %%
    status='Completed';
end

function [particleTbl]=convertCoordinatIntoBBox(coordTable,patchSize,mgDim,mgMaxHW,mgName)
    n=size(coordTable,1);
    mgH=mgDim(1);mgW=mgDim(2);
    nW=floor(mgW/mgMaxHW);
    particleCell=cell(0,2);
    particleIdx=1;
    for pidx=1:n
        row=coordTable(pidx,:);        
        cx=row.x;cy=row.y;name=row.name{1};
        [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchSize);
        cIdx=ceil(y1/mgMaxHW);
        rIdx=ceil(x1/mgMaxHW);
        patchIdx=(rIdx-1)*nW+cIdx;        
        patchX1=(rIdx-1)*mgMaxHW+1;patchX2=patchX1+mgMaxHW-1;
        patchY1=(cIdx-1)*mgMaxHW+1;patchY2=patchY1+mgMaxHW-1;
        fprintf('patchIdx:%d patchX1:%d patchX2:%d patchY1:%d patchY2:%d\n',patchIdx,patchX1,patchX2,patchY1,patchY2);        
        if(x1>=patchX1 && x2 <= patchX2 && y1>=patchY1 && y2<=patchY2)                    
            fpath=strcat(mgName,'_',num2str(patchIdx),'.jpg');
            bbox=[x1,y1,patchSize(1),patchSize(2)];
            particleCell(particleIdx,:)={char(fpath),{double(bbox)}};
            particleIdx=particleIdx+1;
        else
            fprintf('**Particle is at the boundry: x1:%d x2:%d y1:%d y2:%d \n',x1,x2,y1,y2);
        end
    end
    particleTbl= cell2table(particleCell);
end
% Divide the large collage into smalle collage
function divideAndSaveMG(micrograph,mgMaxHW,savePath,savePrefix)
        micrograph=micrograph-min(micrograph(:));
        micrograph=micrograph/max(micrograph(:));        
        [mgH,mgW]=size(micrograph);
        mgIdx=1;
        nH=floor(mgH/mgMaxHW);
        nW=floor(mgW/mgMaxHW);
        for i=1:nH
            offsetX=(i-1)*mgMaxHW;
            x1=offsetX+1;x2=mgMaxHW*i;
            if i==nW
                x2=mgH;
            end
            for j=1:nW
                offsetY=(j-1)*mgMaxHW;
                y1=offsetY+1;y2=mgMaxHW*j;
                if j==nW
                    y2=mgW;
                end
                patch=micrograph(x1:x2,y1:y2);   
                imwrite(patch,strcat(savePath,'/',savePrefix,'_',num2str(mgIdx),'.jpg'));
                mgIdx=mgIdx+1;
            end
        end
end

