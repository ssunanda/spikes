%function plotData(t, originalData, stepSize, duration, globalPlotStartTime, globalPlotEndTime, figureNumber, fileName)
function plotData(t, originalData, firstDifferential, secondDifferential, thirdDifferential, stepSize, duration, globalPlotStartTime, globalPlotEndTime, figureNumber, fileName)
%Plotting function
if globalPlotStartTime == -1
    globalPlotStartTime = 0;
end

if globalPlotEndTime == -1
    globalPlotEndTime = duration;
end

globalPlotStartIndex = max(int32(globalPlotStartTime / stepSize), 1); %Approximate index for plotStartTime, useful for plotting. If plotStartTime = 0, max selects 1
globalPlotEndIndex = min(int32(globalPlotEndTime / stepSize), (length(originalData) - 1)); %Approximate index for plotEndTime, useful for plotting. If plotEndTime is too large, selects the largest number within range
figure(figureNumber) %figureNumber cannot start at 0
hold all
plot(t(globalPlotStartIndex:globalPlotEndIndex), originalData(globalPlotStartIndex:globalPlotEndIndex)); %Plots originalData in specified range
title(fileName); %for specific spikes??
xlabel('Time (s)');
ylabel('Potential (mV)');

%Plot differentials - for testing only!

plot(t(globalPlotStartIndex:(globalPlotEndIndex - 1)), firstDifferential(globalPlotStartIndex:(globalPlotEndIndex - 1)) - 40) %Plots first differential, shifts down for easier viewing
plot(t(globalPlotStartIndex:(globalPlotEndIndex - 2)), secondDifferential(globalPlotStartIndex:(globalPlotEndIndex - 2)) - 50)
plot(t(globalPlotStartIndex:(globalPlotEndIndex - 3)), thirdDifferential(globalPlotStartIndex:(globalPlotEndIndex - 3)) - 60)