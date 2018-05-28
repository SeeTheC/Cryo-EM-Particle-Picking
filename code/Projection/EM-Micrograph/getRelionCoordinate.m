% Read the coordinate from the metadatafile for specific micrograph
function [coordTable,keyword] = getRelionCoordinate(mgFilename,coordMetadataPath)
    parts=split(mgFilename,'_');
    keyword=join(parts(1:end-1),'_');
    keyword=keyword{1};
    bash_script=sprintf('script/extract_coordinates.sh %s %s',keyword,coordMetadataPath);
    system(bash_script);
    coordTable = readtable('result.csv','Delimiter',',');
    %fprintf('Done reading result.csv.\n');
end

