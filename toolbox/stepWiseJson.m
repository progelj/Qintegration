function [swCell,steps]=stepWiseJson(stage,stageDescription,stagePercent,stageTime,swCell,steps,PathResultados);

%Date-Time ISO
dateTimeISO=datestr(datetime,31);

sw.date=dateTimeISO;
sw.label=stage;
sw.percent=stagePercent;
sw.description=stageDescription;
sw.time=stageTime;

swCell{1,steps}=sw;
opt.FileName=strcat(PathResultados,filesep,'stepwise.json');
savejson('',swCell,opt);

steps=steps+1;

[status,result]=system(char(strcat('precisioncli',{' '},'stepwise',{' '},PathResultados)));