function [rawData,headerDicom,infoDicom,paths]=readImag(infoAnalysis,stdSeriesPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%-Nifti volume and header reading
%%%-header.json and info.json loading into Matlab structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

currentPath=infoAnalysis.Studyfolder;
seriesFolders=dir(currentPath);  

% Series Mapping 
seriesMapping={};
currentSeries=loadjson(stdSeriesPath);
for i=1:size(currentSeries.stdseries,2)
    seriesMapping{1,i}=currentSeries.stdseries{1,i}.name;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Iterative folder reading, looking for standard series
for j=1:length(seriesFolders)

    %currentSeries: current subfolder name extracted from reading the actual
    %subfolder name
    currentSeries = seriesFolders(j).name; 
       
    for secs = 1:size(infoAnalysis.series,2)
        
        currentSeriesPath=infoAnalysis.series{1,secs}.folder;

        delim=find(currentSeriesPath==filesep);
        delim=delim(end);
        
        %mappingSeriesName: current subfolder name extracted from
        %analysis.json
        mappingSeriesName=currentSeriesPath(delim+1:end); 
        mappingSeriesSize = size(mappingSeriesName);
        
        if strncmpi(currentSeries,mappingSeriesName,mappingSeriesSize(2)) 
            for indexSM=1:size(seriesMapping,2)
                seriesNameJson=seriesMapping{1,indexSM};
                
                try
                    %If the current series from the analysis json is a
                    %standard series this will return the standard name
                    standardNameJson=infoAnalysis.series{1,secs}.standard;
                catch
                    continue
                end
                
                standardSeriesSize = size(standardNameJson);
                
                if strncmpi(seriesNameJson,standardNameJson,standardSeriesSize(2))               
                    %Check that no first digit will make fieldnames fail.
                    firstChar=seriesNameJson(1);
                    if isstrprop(firstChar,'digit')
                        seriesNameJson=strcat('seq',seriesNameJson);
                    end
                    
                    %%% Folder content reading
                    currentSeriesPath = strcat(currentPath,filesep,currentSeries);
                    fileList = dir(currentSeriesPath);
                    
                    %CHECK IF NIFTI EXISTS. IF NOT WAIT 40 s **************                                                
                    niftiOK = dir(strcat(currentSeriesPath,filesep,'*.nii')); 
                    paused=0;
                    while isempty(niftiOK)
                        'Pause'
                        pause(40)
                        fileList = dir(currentSeriesPath);
                        niftiOK = dir(strcat(currentSeriesPath,filesep,'*.nii'));
                        paused=1;
                    end
                    if paused==1
                        pause(40)
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%************
                    
                    %Browse throgh file list for our required nii and json
                    %files
                    for z=3:length(fileList)
                        currentFile = fileList(z).name;
                        [~, currentSeries, ext] = fileparts(currentFile);
                        switch ext
                            case '.json'
                                if strcmp(currentFile,'header.json')
                                    headerFull=strcat(currentSeriesPath,filesep,'header.json');
                                    dataHeader=loadjson(headerFull);
                                    headerDicom.(seriesNameJson)=dataHeader;
                                end
                                if strcmp(currentFile,'info.json')
                                    infoFull=strcat(currentSeriesPath,filesep,'info.json');
                                    infoHeader=loadjson(infoFull);
                                    infoDicom.(seriesNameJson)=infoHeader;
                                end
                            case '.nii'
                                try
                                    firstCharacter = currentSeries(1);
                                catch
                                    firstCharacter = 'e';
                                end
                                if firstCharacter ~= 'o' && firstCharacter ~= 'c' && firstCharacter ~= 'x'
                                    pathFile = strcat(currentSeriesPath,filesep,currentSeries);
                                    niiPath=strcat(pathFile,'.nii');
                                    try
                                        [headerNii] = nii_read_header(niiPath);   
                                    catch
                                        [headerNii] = load_untouch_nii(niiPath);
                                        headerNii=headerNii.hdr;
                                    end
                                    seriesNameJson=char(seriesNameJson);
                                    header.(seriesNameJson)=headerNii;
                                    try
                                        [vol]= nii_read_volume(headerNii);  
                                    catch
                                        [vol]= load_untouch_nii(niiPath);
                                        vol=vol.img;
                                    end
                                    seriesNameJson=char(seriesNameJson);

                                    volume.(seriesNameJson)=vol;
                                    rawData.header=header;
                                    rawData.volume=volume;
                                    paths.(seriesNameJson)=niiPath;
                                end
                        end
                    end
                end
            end
        end
    end
end

            
            
            










