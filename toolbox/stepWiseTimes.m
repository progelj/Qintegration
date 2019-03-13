function [time,percent]=stepWiseTimes(inputTimes,stageNum,roiTab,varargin)

nVarargs = length(varargin);

if nVarargs>0
    nMask=varargin{1};
    totalTime=varargin{2};
end

time1=inputTimes.time1;
time2=inputTimes.time2;
time3=inputTimes.time3;
time4=inputTimes.time4;
% time5=inputTimes.time5;

switch stageNum
    case 1
        nMasks=size(roiTab,1);
        if ~isscalar(roiTab)
            time=time1+sum(roiTab(1:end,2))*time3+nMasks*(time2+time4);
        else 
            time=time1+time2+time3+time4;
        end
        percent=0;
    case 2
        if ~isscalar(roiTab)
            elapsedTime=time1+(nMask-1)*(time2+time4)+sum(roiTab(1:(nMask-1),2))*time3;
            time=totalTime-elapsedTime;
        else
            elapsedTime=time1;
            time=totalTime-elapsedTime;
        end
        percent= round((elapsedTime/totalTime)*100);
    case 3
        if ~isscalar(roiTab)
            elapsedTime=time1+nMask*time2+(nMask-1)*time4+sum(roiTab(1:(nMask-1),2))*time3;
            time=totalTime-elapsedTime;
        else
            elapsedTime=time1+time2;
            time=totalTime-elapsedTime;
        end
        percent= round((elapsedTime/totalTime)*100);
    case 4
        if ~isscalar(roiTab)
            elapsedTime=time1+nMask*time2+sum(roiTab(1:nMask,2))*time3+(nMask-1)*time4;
            time=totalTime-elapsedTime;
        else
            elapsedTime=time1+time2+time3;
            time=totalTime-elapsedTime;
        end 
        percent= round((elapsedTime/totalTime)*100);
    case 5
        elapsedTime=totalTime;
        time=totalTime-elapsedTime;
        percent= round((elapsedTime/totalTime)*100);
end





