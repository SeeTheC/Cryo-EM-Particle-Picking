%dirPath : Location where PCA cofficient are their
function [dataCoeff] = reduceDimByPCA(pcaCoeff,mu,img)
    %coeff=dlmread(strcat(dirPath,'/pca_coeff.txt'));
    %mu=dlmread(strcat(dirPath,'/data_mean.txt'));
    %x1=coordinate(1);x2=coordinate(2);
    %y1=coordinate(3);y2=coordinate(4);    
    %img=collage(x1:x2,y1:y2);    
    vector=reshape(img,1,size(img,1)*size(img,2));
    dataCoeff=bsxfun(@minus,vector,mu)*pcaCoeff;
end

