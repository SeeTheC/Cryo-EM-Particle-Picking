% Predict the label on Test Datapoint
function [label,positiveScore,negativeScore] = perdictLabel(modelType,model,XTest)    
    if modelType == ModelType.CompactSVM
        [predLabel,score] = predict(model,XTest);
    elseif modelType == ModelType.RandomForest
        [predLabel,score] = predict(model,XTest);
    elseif modelType == ModelType.DecisionTree
        [predLabel,score] = predict(model,XTest);
    end
    label=predLabel;
    negativeScore=score(:,1);
    positiveScore=score(:,2);
   
end

