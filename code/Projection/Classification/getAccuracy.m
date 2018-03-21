% Return the Model Accuracy
function [ accuracy ] = getAccuracy(trueLabel,predLabelCell)
    count = 0;
    n=size(trueLabel,1);
    for i=1:n
        if num2str(trueLabel(i)) == predLabelCell{i}
            count = count +1;
        end
    end
    accuracy= count*100/n;
end

