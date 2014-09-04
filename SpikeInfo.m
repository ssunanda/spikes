classdef SpikeInfo
    properties
        spikeNumber
        samplingRate
        startIndex
        startTime
        startValue
        peakTime
        peakOriginalIndex
        peakValue
        ISI
        width
        riseTime
        riseRate
        %pastPeakMinimum
        %height
    end
end

%The parameters are: 
%time at start of spike in s (spikeStartTime) = as given by function getSpikeStartTime, given by one of functions secondDerivativeMethod,
%thirdDerivativeMethod, firstDerivativeMethod, secondThirdAverageMethod...
%time at end of spike in s (spikeEndTime) = as given by function getSpikeEndTime
%duration in s = as given by spikeEndTime - spikeStartTime
%spike width in s = width at half max given by getSpikeWidth
%time at peak in s (peakTime) 
%peak value in mV (peakValue)
%rise time in s = peakTime - spikeStartTime
%fall time in s = spikeEndTime - peakTime
%first local minimum after peak in mV (getPastPeakMinimum)
%spike height in mV = peakValue - pastPeakMinimum

%csv properties
%open csvs and select 
%store and query data