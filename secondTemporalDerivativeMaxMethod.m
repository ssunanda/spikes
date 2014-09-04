function [halfMaxIndex] = secondTemporalDerivativeMaxMethod(secondDifferential, findStartTime, findEndTime, originalData, duration, stepSize)

findStartIndex = max(int32(findStartTime ./ stepSize), 1)%Approximate index for findStartTime, useful for plotting. If plotStartTime = 0, max selects 1
findEndIndex = min(int32(findEndTime ./ stepSize), (length(originalData) - 1))

[maxValue, maxIndex] = max(secondDifferential(findStartIndex:(findEndIndex - 2)))%indices and values of second deriv max in window
halfMaxValue = .5.*maxValue
halfMaxRange = secondDifferential(findStartIndex:findEndIndex);
[halfMaxRowRange, halfMaxColRange] = find(halfMaxRange > halfMaxValue, 1, 'last');
halfMaxIndex = halfMaxRowRange + findStartIndex - 2


%halfMaxIndexRange = int32(halfMaxIndexRange)
%halfMaxIndex = halfMaxIndexRange + findStartIndex - 2

%find(x<0.9,1,'last')
%halfMaxValueAdj = secondDifferential(halfMaxIndex)

%maxIndex = maxIndex; %-3 shift 
%maxIndex = maxIndex + findStartIndex - 1; % subtract one because indexing

%Citation: Wilent and Contreras Journal of Neuroscience
%2005
%http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0012001
%Bugaysen et al 2010 Plos One