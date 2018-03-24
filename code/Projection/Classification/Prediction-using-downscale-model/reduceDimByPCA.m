%dirPath : Location where PCA cofficient are their
function [dataCoeff] = reduceDimByPCA(pcaCoeff,mu,img)
    vector=reshape(img,1,size(img,1)*size(img,2));
    dataCoeff=bsxfun(@minus,vector,mu)*pcaCoeff;
end

