% Returns the files name of the give dir in sorted order
function [ fldFileNames ] = getDirFilesName(dirpath)
    folder = dir(dirpath);
    fldFileNames =natsortfiles({folder.name});    
    fldFileNames=fldFileNames(1,3:end);
end

