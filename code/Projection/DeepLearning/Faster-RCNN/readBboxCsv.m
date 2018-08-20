function [newtbl,csv] = readBboxCsv(filename)
    %col 1: name
    %col 2,3,4,5:[x,y,h,w]
    table = readtable(filename);
    sortedTbl = sortrows(table,[1]);
    prevfile='';
    n=size(table,1);
    particleCell=cell(0,2);  
    idx=0;
    for i=1:n
        row=sortedTbl(i,:);
        name=row{1,1}{1};
        if(strcmp(prevfile,name))
            bbox=[bbox;row{1,3},row{1,2},row{1,4},row{1,5}];   
            particleCell(idx,:)={char(name),{double(bbox)}};
        else
            idx=idx+1;
            bbox=[row{1,3},row{1,2},row{1,4},row{1,5}];   
            particleCell(idx,:)={char(name),{double(bbox)}};
        end  
        prevfile=name;
    end    
    newtbl=cell2table(particleCell);
    newtbl.Properties.VariableNames = {'name','bbox'};    
    csv=table;
end

