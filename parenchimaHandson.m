function parenchimaHandson(resultsPath)

close all
clc

%%% For debugging purposes
% resultsPath = fullfile(pwd,'PARENCHIMA_HANDSON','CRANEO20190220','biomarker','difusionADC_5c7fa556fa697a467cb729f7_06_03_2019_10_47')
%%%

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% Image data and roi reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    error = 1;
    
    %% Add dependencies to PATH
    addpath(genpath('toolbox'))
    
    %%
    %%%%%%%%%%%%%%%%%
    %%% Load analysis.json, stepwiseConfig.json and standardSeries.json
    %%%%%%%%%%%%%%%%%

    infoAnalysis=loadjson([resultsPath '/analysis.json']);
    swInfo=loadjson('stepwiseConfig.json');
    stdSeriesPath=loadjson('standardSeries.json');

    %%%%%%%%%%%%%%%%%
    
    %% Stepwise
    swProv=cell(1,1);
    steps=1;
    roiTab = 0;   
    [totalTime,stagePercent]=stepWiseTimes(swInfo.times,1,roiTab);
    [swProv,steps]=stepWiseJson(swInfo.labels.label1,swInfo.descriptions.description1,stagePercent,totalTime,swProv,steps,resultsPath);
    
    %%
    %%%%%%%%%%%%%%%%%
    %%% Create Result and Report folders in analysis folder
    %%%%%%%%%%%%%%%%%


    resultsFolder = [resultsPath '/Results'];
    mkdir(resultsFolder);
    
    reportFolder= [resultsPath '/Reports'];
    mkdir(reportFolder);

    %%%%%%%%%%%%%%%%%
    
    %% NifTi and header reading
    %-header.json and info.json loading into Matlab structures
    [rawData, headerDicom, infoDicom, ~]= readImag(infoAnalysis,stdSeriesPath);  
    strucVolum=cellstr(fieldnames(rawData.volume));
    nameStruc=strucVolum{1};
    headerData=extractDataHeader(headerDicom.(nameStruc));
    volumeFull=(rawData.volume.(nameStruc));
    
    %%%%%%%%%%%%%%%%%
    % Reorient volume to the axial plane
    %%%%%%%%%%%%%%%%%

    % volumeFull =

    %%%%%%%%%%%%%%%%%
 
    
    %% roi:
    %-Convert from ROI definitions to binary masks
    try
        [maskFull,sliceNumber,~,~,roiInfoAll]= roi(infoAnalysis, infoDicom, headerDicom, volumeFull, nameStruc);
    catch
    end
        
    %Initialize docNode structures that will be converted into report.xml
    %and result.xml
    docNodeProv=0;
    docNodeProvReport=0;
    
catch err

    errorXML(err,error,resultsPath);
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    %exit
    
end


try
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Data preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Stepwise
    [timeLeft,stagePercent]=stepWiseTimes(swInfo.times,2,roiTab,1,totalTime);
    [swProv,steps]=stepWiseJson(swInfo.labels.label2,swInfo.descriptions.description2,stagePercent,timeLeft,swProv,steps,resultsPath);
    
    %%
    error = 2;
    
    maskId = fieldnames(maskFull);
    maskId=char(maskId{1,:});
    mask=maskFull.(maskId);
    sliceNumbersMask=sliceNumber.(maskId);
    
    roiInfo.id=roiInfoAll.id(1);
    roiInfo.label=roiInfoAll.label(1);
    roiInfo.text=roiInfoAll.text(1);
    roiInfo.name=roiInfoAll.name(1);
    
catch err

    errorXML(err,error,resultsPath);
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    %exit

end

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Data Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Stepwise
    [timeLeft,stagePercent]=stepWiseTimes(swInfo.times,3,roiTab,1,totalTime);
    [swProv,steps]=stepWiseJson(swInfo.labels.label3,swInfo.descriptions.description3,stagePercent,timeLeft,swProv,steps,resultsPath);
    
    error = 3; 
    
    %%
    %%%%%%%%%%%%%%%%%
    %%% Calculate the mean, standard deviation, median and percentiles 25 and 75 of the image values inside the ROI
    %%%%%%%%%%%%%%%%%
%     
%     volumeMean = 
%     volumeStd = 
%     volumeMedian = 
%     volumeP25 = 
%     volumeP75 = 

    %%%%%%%%%%%%%%%%%
    
    %analysis is a structure that will help create report.xml and
    %result.xml
    analysis.Body.histogram.media=sprintf('%0.4e', volumeMean);
    analysis.Body.histogram.std=sprintf('%0.4e', volumeStd);
    analysis.Body.histogram.mediana=sprintf('%0.4e', volumeMedian);
    analysis.Body.histogram.p25=sprintf('%0.4e', volumeP25);
    analysis.Body.histogram.p75=sprintf('%0.4e', volumeP75);
    
catch err

    errorXML(err,error,resultsPath);
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    exit

end

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Image storage and xml files generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Stepwise
    [timeLeft,stagePercent]=stepWiseTimes(swInfo.times,4,roiTab,1,totalTime);
    [swProv,steps]=stepWiseJson(swInfo.labels.label4,swInfo.descriptions.description4,stagePercent,timeLeft,swProv,steps,resultsPath);
    
    error = 4;
    analysisReport = analysis;
    
    %% ROI folder in Result and Report
    resultsFolderROI = strcat(resultsFolder,filesep,maskId(5:end));
    mkdir(resultsFolderROI);
    reportFolderROI = strcat(reportFolder,filesep,maskId(5:end));
    mkdir(reportFolderROI);
    
    %% Analysis info
    %%% Complete Analysis structure with optional info
    NameZones{1,1}='Body';

    ZonesEs = strcat('Region de interes- ',num2str(1));
    Zones{1,1}=ZonesEs;
    ZonesEn = strcat('Region of interest- ',num2str(1));
    Zones{2,1}=ZonesEn;
    
    analysis.NombresEN=NameZones;
    analysis.DescripcionEN=Zones;

    identifier=infoAnalysis.analysis;
    
    %% Create result.xml
    %flagEnd = 1 indicates this is the final step of the analysis and no 
    %more ROIs need to be analyzed. If this is the case, the result.xml
    %and report.xml will be created in this iteration.
    flagEnd = 1;
    docNodeProv=resultXML(analysis, identifier, resultsFolder, docNodeProv, flagEnd, roiInfo);
    
    %% Report Images %%%
    reportFolderROIImages= strcat(reportFolderROI,filesep,'Images');
    mkdir(reportFolderROIImages);

    % Save Image with Mask
    
    %%%%%%%%%%%%%%%%%
    %%%% TO FILL %%%%
    %%%%%%%%%%%%%%%%%
    
    print('-djpeg', fullfile(reportFolderROIImages,'1.jpg'), '-r300');
    
    
    % Plot histogram

    %%%%%%%%%%%%%%%%%
    %%%% TO FILL %%%%
    %%%%%%%%%%%%%%%%%
    
    print('-djpeg', fullfile(reportFolderROIImages,'2.jpg'), '-r300');
    
    
    imagePath.Body1.dirPhoto = strcat(reportFolderROIImages,filesep);
    imagePath.Body1.NamePhoto = '1.jpg';
    imagePath.Body2.dirPhoto = strcat(reportFolderROIImages,filesep);
    imagePath.Body2.NamePhoto = '2.jpg';
    
    %%%%%%%%%%%%%%%%%
    % pluginName=
    %%%%%%%%%%%%%%%%%

    %% Create report.xml
    docNodeProvReport=reportXML(analysisReport, identifier, docNodeProvReport, pluginName, flagEnd, headerData, reportFolder, imagePath, roiInfo);
    
catch err

    errorXML(err,error,resultsPath);
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    exit

end


try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Database storage & exit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Stepwise
    [timeLeft,stagePercent]=stepWiseTimes(swInfo.times,5,roiTab,1,totalTime);
    [swProv,steps]=stepWiseJson(swInfo.labels.label5,swInfo.descriptions.description5,stagePercent,timeLeft,swProv,steps,resultsPath);
    
    error = 5;
    
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    
catch err
    
    errorXML(err,error,resultsPath);
    [status,result]=system(char(strcat('precisioncli',{' '},'result',{' '},resultsPath)));
    exit
    
end

exit

