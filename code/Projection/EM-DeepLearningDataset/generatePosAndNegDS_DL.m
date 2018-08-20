function [status,finalTrainTbl,finalTestTbl] = generatePosAndNegDS_DL(mgPath,patchSize,coordMetadataPath,testPercent,basepath)
    status='Incomplete';
    %% Init
    % mgMaxHW : Will be used for partitioning the large MicroGraph into
    % submicrograph.
    mgMaxHW=1000;
    
    timestamp=datestr(now,'dd-mm-yyyy_HH:MM:SS');
    
    savepath=strcat(basepath,'/dl_projection_mghw_',num2str(mgMaxHW),'_ts_',timestamp);
    saveTrainPath=strcat(savepath,'/Train');
    saveTrainPathImg=strcat(saveTrainPath,'/img');
    trainBBoxPath=strcat(saveTrainPath,'/train_bbox.csv');
    
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
    %% Process : Train
    fprintf('----------------[Train IMAGES]----------------------\n');
    finalTrainTbl = cell2table(cell(0,2));
    finalTrainTbl.Properties.VariableNames = {'name','bbox'};
    for m=1:nTrain
        mgName=fileNameList{m};
        mgFile=strcat(mgPath,'/',mgName);
        fprintf('Processing mg #%d:%s\n',m,mgName);        
        [micrograph,~,~,~,~]=ReadMRC(mgFile);
        [coordTable,keyword] = getRelionCoordinate(mgName,coordMetadataPath);
        
        divideAndSaveMG(micrograph,mgMaxHW,saveTrainPathImg,keyword)        
        [particleTbl]=convertCoordinatIntoBBox(coordTable,patchSize,size(micrograph),mgMaxHW,keyword,saveTrainPathImg);
        finalTrainTbl=[finalTrainTbl;particleTbl];
        %noOfParticle=size(coordTable,1)
    end
    % Save train table
    writetable(finalTrainTbl,strcat(trainBBoxPath));
     %% Process : Test
    fprintf('----------------[TEST IMAGES]----------------------\n');
    finalTestTbl = cell2table(cell(0,2));
    finalTestTbl.Properties.VariableNames = {'name','bbox'};    
    for m=nTrain+1:noOfMg
        mgName=fileNameList{m};
        mgFile=strcat(mgPath,'/',mgName);
        fprintf('Processing mg #%d:%s\n',m,mgName);        
        [micrograph,~,~,~,~]=ReadMRC(mgFile);
        [coordTable,keyword] = getRelionCoordinate(mgName,coordMetadataPath);
        
        divideAndSaveMG(micrograph,mgMaxHW,saveTestPathImg,keyword)        
        [particleTbl]=convertCoordinatIntoBBox(coordTable,patchSize,size(micrograph),mgMaxHW,keyword,saveTestPathImg);
        finalTestTbl=[finalTestTbl;particleTbl];
        %noOfParticle=size(coordTable,1)
    end
    % Save train table
    writetable(finalTestTbl,strcat(testBBoxPath));
    %%
    status='Completed';
end

function [particleTbl]=convertCoordinatIntoBBox(coordTable,patchSize,mgDim,mgMaxHW,mgName,saveTrainPath)
    n=size(coordTable,1);
    mgH=mgDim(1);mgW=mgDim(2);
    nW=floor(mgW/mgMaxHW);
    nH=floor(mgH/mgMaxHW);
    particleCell=cell(0,2);
    particleIdx=1;
    debug=false;
    for pidx=1:n
        row=coordTable(pidx,:);        
        cx=row.x;cy=row.y;name=row.name{1};
        [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchSize);
        cIdx=ceil(y1/mgMaxHW);
        rIdx=ceil(x1/mgMaxHW);
        if rIdx>nH
            rIdx=nH;
        end
        if cIdx>nW
            cIdx=nW;
        end
        patchIdx=(rIdx-1)*nW+cIdx;        
        patchX1=(rIdx-1)*mgMaxHW+1;patchX2=patchX1+mgMaxHW-1;
        patchY1=(cIdx-1)*mgMaxHW+1;patchY2=patchY1+mgMaxHW-1;
        %fprintf('patchIdx:%d patchX1:%d patchX2:%d patchY1:%d patchY2:%d\n',patchIdx,patchX1,patchX2,patchY1,patchY2);        
        if(x1>=patchX1 && x2 <= patchX2 && y1>=patchY1 && y2<=patchY2)                    
            fpath=strcat(mgName,'_',num2str(patchIdx),'.jpg');
            bbox=[mod(x1,mgMaxHW),mod(y1,mgMaxHW),patchSize(1),patchSize(2)];
            particleCell(particleIdx,:)={char(fpath),{double(bbox)}};
            particleIdx=particleIdx+1;
            % Debug
            if(debug==true)
                debug=false;
                f=strcat(saveTrainPath,'/',fpath);
                img=imread(f);
                imshow(img,[]),hold on, rectangle('Position',[bbox(2),bbox(1),patchSize(2),patchSize(1)],'EdgeColor', 'r','LineWidth', 1,'LineStyle','-');
            end
         else
            fprintf('**Particle is at the boundry: x1:%d x2:%d y1:%d y2:%d \n',x1,x2,y1,y2);
        end
    end
    particleTbl= cell2table(particleCell);    
    particleTbl.Properties.VariableNames = {'name','bbox'};
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
            if i==nH
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

