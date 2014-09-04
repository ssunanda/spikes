function getSpikes(fileName)

%Written by Sunanda Sharma (help from GT Franzesi, A Singer, M. Tsitsiklis, Victor Mours, and Kristjan Eerik
%Kaseniit) Last edited 08.30.14
%Used in conjunction with abfload.m

%Constants and Parameters
threshold = -10; %Depolarization threshold in mV
windowHalfWidth = 0.030; %Time plotted before and after peak in s
groupCutoff = 0.005; %Maximum time difference between peaks to consider spikes as part of a group in s
getSpikeStartIndex = @plotspikethresh; %@secondTemporalDerivativeMaxMethod; %Calculates spike start time, given by one of functions secondDerivativeMethod,thirdDerivativeMethod, firstDerivativeMethod, secondThirdAverageMethod...
globalPlotStartTime = -1; %Default start value for full data plot; if set to -1, will automatically be reset to 0
globalPlotEndTime = -1; %Default end value for full data plot; if set to -1, will automatically be set to duration

%Load abf ephys data file, assumes equal sampling intervals

[completeData, samplingInterval, header] = abfload(fileName);
originalData = completeData(:, 1);%fulldata is in first column of matrix completeData; originaldata is under -45mv cutoff
[path, name, extension] = fileparts(fileName); %Splits up fileName
% for i = 1:length(originalData)
%     if originalData(i) > -45 %for 100 consecutive, make NaN
    

%Convert indices to time in seconds
duration = (length(completeData-1)*samplingInterval)/1000000
%samplingRate = 20000;%length(originalData) / duration; %should be 20000 samples/sec
stepSize = duration / (length(originalData) - 1) %stepSize = total time / number of intervals (which is number of datapoints - 1)
%should be .00005
t = 0:stepSize:duration; %Makes an array of time values corresponding with data 

%Compute 1st, 2nd, 3rd differentials
%Differentials are dValue e.g. by diff function (discrete space); derivatives are dValue/dt
%N.B. Each successive differential array is one less in length

firstDifferential = diff(originalData);
secondDifferential = diff(firstDifferential);
thirdDifferential = diff(secondDifferential);

%Plot original data and differentials against time in seconds

plotData(t, originalData, firstDifferential, secondDifferential, thirdDifferential, stepSize, duration, globalPlotStartTime, globalPlotEndTime, 1, fileName)
%plot(t, originalData)
hold on
title(fileName)
xlabel('Time (s)')
ylabel('Potential (mV)')
Filename = [name,'full'];
print('-djpeg', Filename)
hold off

%Find peaks above a threshold
%A peak is the highest point in a spike, which is a depolarization event
%If no peak, returns error message

depolarizedIndices = find(originalData > threshold); %Indices of all possible peaks (values above threshold)

if isempty(depolarizedIndices) 
    display('There are no values above threshold.') 
    return
end
    
depolarizedValues = originalData(depolarizedIndices);
depolarizedTimes = t(depolarizedIndices);
[peakValues, peakIndices] = findpeaks(depolarizedValues); %Finds actual peaks (local maxima and their indices)
numPeaks = length(peakIndices) %peakIndices are not the indices in originalData
peakTimes = t(depolarizedIndices(peakIndices));

%Categorize into single spikes versus multiple spikes within groupCutoff s of each
%other by Grouping and plot histograms %TODO

% %Finds groups
% groups{1} = [ peakTimes(1) ]; %Initializes a matrix groups with the first cell containing the time of the first peak, first thing needed so you can do comparison to previous 
% j = 1; %i iterates over peaks, j iterates over groups
% for i = 2:(length(peakTimes)) %Starts at 2 because initial entry is already in matrix
%     if peakTimes(i) - peakTimes(i - 1) < groupCutoff %Compares adjacent entries and merges into group
%         groups{j} = [ groups{j} peakTimes(i) ];%creates group of peaks less than cutoff apart
%     else
%         j = j + 1;
%         groups{j} = [ peakTimes(i) ]; %if more than cutoff apart, new cell is created
%     end
% end
% 
% %Finds group sizes separates singlets
% groupSizes = []; %Initialize matrix groupSizes
% singlets = []; 
% for i = 1:length(groups)
%     groupSize = length(groups{i});
%     %here put code for if you want just singlets, just doublets, just
%     %potential bursts, or just other things; peaks(i) is the corresponding
%     %peak value the peak time
%     fprintf('Group %d (Size: %d): %s\n', i, groupSize, sprintf(' %f', groups{i})) %Prints groups by number, size, timepoints,new line for new group
%     groupSizes = [ groupSizes groupSize ];
%     if groupSize == 1
%         singlets = [ singlets groups{i}(1) ];
%     end
% end
    
    %Easy identification of groups
%     if groupSize>=2
%         if groups{i}(1) > plotStart & groups{i}(end) < plotEnd
%             plot(groups{i}, ones(groupSize) * 35, 'r-'); % draws a line at 35 over groups; need as many x values as y values to get continuous line
%         end
%     end

%Find parameters for each single spike; worry about bigger groups later
%replaced "singlets" below with peakTimes
%look at std dev and percentages

allSpikes = [];

for i = 1:length(peakTimes) %1:length(singlets)
    s = SpikeInfo;
    fprintf('Spike #%d\n', i)
    s.spikeNumber = i;
    %s.samplingRate = samplingRate; %samples per second
    %findStart = peakTimes(i) - (windowHalfWidth./10);
    if i == 1 
        findStart = 0;
    else
    findStart = peakTimes(i-1);
    end
    findEnd = peakTimes(i);

    %s.startIndex = plotspikethresh(originalData, .010, t);
    s.startIndex = secondTemporalDerivativeMaxMethod(secondDifferential, findStart, findEnd, originalData, duration, stepSize);
    s.startTime = t(s.startIndex);
    s.startValue = originalData(s.startIndex);
    s.peakTime = peakTimes(i);
    %s.endTime = singlets(i) + .050; %getSpikeEndTime; %TODO
    %s.duration = s.endTime - s.startTime;
    s.peakOriginalIndex = find(t == peakTimes(i));
    s.peakValue = originalData(s.peakOriginalIndex);
    if i == 1
        s.ISI = NaN;
    else
    s.ISI = peakTimes(i) - peakTimes(i - 1);
    end
    s.width = (double(abs(s.peakOriginalIndex - s.startIndex)))*stepSize;%in secs 
    s.riseTime = s.peakTime - s.startTime;
    s.riseRate = (s.peakValue - s.startValue)./s.riseTime
    %s.fallRate
    %s.fallTime = s.endTime - s.peakTime;
    %s.height = s.peakValue - s.pastPeakMinimum
    %maybe s.waveform
    allSpikes = [allSpikes s];
end


disp(allSpikes) %matrix with all data

%Plot windows of interest around each peak

% for i=1:length(allSpikes);
%     s = allSpikes(i);
%     plotData(t, originalData, stepSize, duration, s.peakTime - windowHalfWidth, s.peakTime + windowHalfWidth, i + 1, fileName);
%     hold on;
%     plot(s.startTime, originalData(s.startIndex), 'r.', 'markersize', 20)
%     legend('Original Data', 'Spike Start');
%     titleName = num2str(name);
%     titleNumber = num2str(i);
%     title(strcat(titleName,' peak', titleNumber));
% %   plot([ s.startTime s.startTime ], [ 10 -80 ], 'k') for line
%     Filename = [name,'peak',num2str(i)];
%     print('-djpeg', Filename);
% end 
% 
% ISIvPeakValue = figure('Name', 'ISI vs. Peak Value');
% datacursormode on
% xlabel('ISI (sec)');
% ylabel('Peak Value (mV)');
% if s.ISI(1) == NaN
%     for i = 2:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, peakValue, 'fill');
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.peakValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvPeakValue'];
%         print('-djpeg', Filename);
%     end
% else 
%     for i=1:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.peakValue, 'fill');
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.peakValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvPeakValue'];
%         print('-djpeg', Filename);
%     end
% end
% 
% ISIvRiseRate = figure('Name', 'ISI vs. Rise Rate');
% datacursormode on
% xlabel('ISI (sec)');
% ylabel('Rise Rate (mV/sec)');
% if s.ISI(1) == NaN
%     for i = 2:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.riseRate, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.riseRate, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvRiseRate'];
%         print('-djpeg', Filename)
%     end
% else 
%     for i=1:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.riseRate, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.riseRate, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvRiseRate'];
%         print('-djpeg', Filename)
%     end
% end
% 
% ISIvStartValue = figure('Name', 'ISI vs. Start Value');
% datacursormode on
% xlabel('ISI (sec)');
% ylabel('Start Value (mV)');
% if s.ISI(1) == NaN
%     for i = 2:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.startValue, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.startValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvStartValue'];
%         print('-djpeg', Filename)
%     end
% else 
%     for i=1:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.startValue, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.startValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvStartValue'];
%         print('-djpeg', Filename)
%     end
% end
% 
% ISIvWidth = figure('Name', 'ISI vs. Width');
% datacursormode on
% xlabel('ISI (sec)');
% ylabel('Width (sec)');
% if s.ISI(1) == NaN
%     for i = 2:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.width, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.width, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvWidth'];
%         print('-djpeg', Filename)
%     end
% else 
%     for i=1:length(allSpikes)
%         s = allSpikes(i);
%         hold all
%         scatter(s.ISI, s.width, 'fill')
%         set(gca, 'xscale', 'log');
%         dataLabels = num2str(s.spikeNumber','%d');
%         text(s.ISI, s.width, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%         Filename = [name,'ISIvWidth'];
%         print('-djpeg', Filename)
%     end
% end
% 
% peakValuevriseRate = figure('Name', 'Peak Value vs. Rise Rate');
% datacursormode on
% xlabel('Peak Value (mV)');
% ylabel('Rise Rate (mV/sec)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.peakValue, s.riseRate, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.peakValue, s.riseRate, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'PeakValueVRiseRate'];
%     print('-djpeg', Filename)
% end
% 
% peakValuevstartValue = figure('Name', 'Peak Value vs. Start Value');
% datacursormode on
% xlabel('Peak Value (mV)');
% ylabel('Start Value (mV)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.peakValue, s.startValue, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.peakValue, s.startValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'PeakValuevStartValue'];
%     print('-djpeg', Filename)
% end
% 
% peakValuevWidth = figure('Name', 'Peak Value vs. Width');
% datacursormode on
% xlabel('Peak Value (mV)');
% ylabel('Width (sec)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.peakValue, s.width, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.peakValue, s.width, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'PeakValuevWidth'];
%     print('-djpeg', Filename)
% end
% 
% riseRatevStartValue = figure('Name', 'Rise Rate vs. Start Value');
% datacursormode on
% xlabel('Rise Rate (mV/sec)');
% ylabel('Start Value (mV)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.riseRate, s.startValue, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.riseRate, s.startValue, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'RiseRatevStartValue'];
%     print('-djpeg', Filename)
% end
% 
% riseRatevWidth = figure('Name', 'Rise Rate vs. Width');
% datacursormode on
% xlabel('Rise Rate (mV/sec)');
% ylabel('Width (sec)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.riseRate, s.width, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.riseRate, s.width, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'RiseRatevWidth'];
%     print('-djpeg', Filename)
% end
% 
% StartValuevWidth = figure('Name', 'Start Value vs. Width');
% datacursormode on
% xlabel('Start Value (mV)');
% ylabel('Width (sec)');
% for i=1:length(allSpikes)
%     s = allSpikes(i);
%     hold all
%     scatter(s.startValue, s.width, 'fill')
%     dataLabels = num2str(s.spikeNumber','%d');
%     text(s.startValue, s.width, dataLabels, 'horizontal', 'left', 'vertical', 'bottom')
%     Filename = [name,'StartValuevWidth'];
%     print('-djpeg', Filename)
% end






