function docNode=reportXML(reportAnalysis, identifier,  docNode, pluginName, flagEnd, patientData, reportFolder, imagePath, roiInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% report.xml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tagsName = {'biomarker', 'properties', 'identifier','name', 'patient', ... 
        'nhc', 'sex', 'birthdate',...
        'lesion',  'zone', 'output', 'statistic',  'value'};

    if docNode==0
        docNode = com.mathworks.xml.XMLUtils.createDocument('biomarker');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Propiedades   

        propertiesElement = docNode.createElement(strcat(tagsName(2)));
        docNode.getDocumentElement.appendChild(propertiesElement);

        nameElement = docNode.createElement(strcat(tagsName(4)));
        pluginNameText = docNode.createTextNode(strcat(pluginName));
        docNode.getDocumentElement.appendChild(pluginNameText);
        docNode.getDocumentElement.appendChild(nameElement);
        nameElement.appendChild(pluginNameText);

        identifierElement = docNode.createElement(strcat(tagsName(3)));
        identifierText = docNode.createTextNode(sprintf('%s',identifier));
        docNode.getDocumentElement.appendChild(identifierText);
        docNode.getDocumentElement.appendChild(identifierElement);
        identifierElement.appendChild(identifierText);

    %     NombreIdentificadorROI = docNode.createElement('roiId');
    %     nombreIdenROI = docNode.createTextNode(sprintf('%s',maskId));
    %     docNode.getDocumentElement.appendChild(nombreIdenROI);
    %     docNode.getDocumentElement.appendChild(NombreIdentificadorROI);
    %     NombreIdentificadorROI.appendChild(nombreIdenROI);

        propertiesElement.appendChild(nameElement);
        propertiesElement.appendChild(identifierElement);
    %     PropiedadesBiomarcador.appendChild(NombreIdentificadorROI);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Datos Pacientes
        DICOMTags={'studyDate','modality','institutionName',...
                            'PixelSpacing1', 'PixelSpacing2','spacingBetweenSlices',...
                            'sliceThickness','studyDescription' , 'patientName','patientID',  ...
                            'birthdate', 'sex','TR','TE','FOV','rows', 'columns','intercept','slope'
                           };

        patientDataFieldnames = cellstr(fieldnames(patientData)); 
        studyReportElement = docNode.createElement(strcat('StudyReport'));
        docNode.getDocumentElement.appendChild(studyReportElement);

        for i=1:size(patientDataFieldnames,1)
            patientDataVariable= char(patientDataFieldnames(i));
            patientDataValue = patientData.(patientDataVariable);

            DICOMTagElement= docNode.createElement(strcat(DICOMTags(i)));
            patientDataValueText = docNode.createTextNode(strcat(patientDataValue));
            docNode.getDocumentElement.appendChild(patientDataValueText);
            docNode.getDocumentElement.appendChild(DICOMTagElement);
            DICOMTagElement.appendChild(patientDataValueText);
            studyReportElement.appendChild(DICOMTagElement);
        end

    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    analysisReportElement = docNode.createElement('AnalysisReport');
    docNode.getDocumentElement.appendChild(analysisReportElement);


%%%%%%% Info ROI 

    fieldsRoiInfo = cellstr(fieldnames(roiInfo));
    sizeRoiInfo = size(fieldsRoiInfo);
    structRoiInfo = docNode.createElement(strcat('RoiInfo'));
    docNode.getDocumentElement.appendChild(structRoiInfo);
    for i=1:sizeRoiInfo(1) 
        fieldRoiInfo = char(fieldsRoiInfo(i));
        valueFieldRoiInfo = roiInfo.(fieldRoiInfo);
        label = docNode.createElement(strcat(fieldRoiInfo));
        value = docNode.createTextNode(strcat(valueFieldRoiInfo));
        docNode.getDocumentElement.appendChild(value);
        docNode.getDocumentElement.appendChild(label);
        label.appendChild(value);
        structRoiInfo.appendChild(label);
    end

%%%%%%% Direcciones imagenes Jasper

    if isstruct(imagePath)
        imagePathCell = cellstr(fieldnames(imagePath)); 
        sizeImagePathCell = size(imagePathCell);
        reportImagesElement = docNode.createElement(strcat('ReportImages'));
        docNode.getDocumentElement.appendChild(reportImagesElement);

        imageDefinition={'dirPhoto','namePhoto'};
        a=1;
        for i=1:1:sizeImagePathCell(1) 
            imagePathVariable = char(imagePathCell(i));
            imagePathValue = imagePath.(imagePathVariable);
            imagePathValueFields = cellstr(fieldnames(imagePathValue));   
            sizeImagePathFields = size(imagePathValueFields);

            for j=1:1:sizeImagePathFields(2)
                DICOMTagElement= docNode.createElement(strcat(imageDefinition(1),num2str(a)));
                imagePathChar=char(imagePathValueFields(1));
                imagePathCharValue=imagePathValue.(imagePathChar);
                patientDataValueText = docNode.createTextNode(strcat(imagePathCharValue));
                docNode.getDocumentElement.appendChild(patientDataValueText);
                docNode.getDocumentElement.appendChild(DICOMTagElement);
                DICOMTagElement.appendChild(patientDataValueText);

                DICOMTagElement2 = docNode.createElement(strcat(imageDefinition(2),num2str(a)));
                imageNameChar=char(imagePathValueFields(2));
                imageNameCharValue=imagePathValue.(imageNameChar);
                patientDataValueText2 = docNode.createTextNode(strcat(imageNameCharValue));
                docNode.getDocumentElement.appendChild(patientDataValueText2);
                docNode.getDocumentElement.appendChild(DICOMTagElement2);
                DICOMTagElement2.appendChild(patientDataValueText2);
                
                a=1+a;
            end
            reportImagesElement.appendChild(DICOMTagElement);
            reportImagesElement.appendChild(DICOMTagElement2);
        end  
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Estructura datos

    fieldsReportAnalysis = cellstr(fieldnames(reportAnalysis)); 
    numberFieldsReportAnalysis = size(fieldsReportAnalysis);

    for i=1:1:numberFieldsReportAnalysis(1)
        a=1; 
        zoneName = char(fieldsReportAnalysis(i));
        allVariables = reportAnalysis.(zoneName);
        allVariablesCell = cellstr(fieldnames(allVariables));   
        variablesSize = size(allVariablesCell);
       
        lesionElement = docNode.createElement(strcat(tagsName(9)));
        docNode.getDocumentElement.appendChild(lesionElement);
        
        zoneElement = docNode.createElement(strcat(tagsName(10)));
        zoneText = docNode.createTextNode(strcat(fieldsReportAnalysis(i)));
        docNode.getDocumentElement.appendChild(zoneText);
        zoneElement.appendChild(zoneText);
        
        lesionElement.appendChild(zoneElement);
        
        for j=1:1:variablesSize(1)      
            
            
            variableName = char(allVariablesCell(j));
            allStatistics = reportAnalysis.(zoneName).(variableName);
            allStatisticsCell = cellstr(fieldnames(allStatistics));   
            statisticsSize = size(allStatisticsCell);
            
            outputElement = docNode.createElement(strcat(tagsName(11)));
            variableNameText= docNode.createTextNode(strcat(variableName));
            docNode.getDocumentElement.appendChild(variableNameText);
            outputElement.appendChild(variableNameText);
            
            lesionElement.appendChild(outputElement);
            
            for k=1:1:statisticsSize(1) 
                variableValue = char(allStatisticsCell(k));
                value = reportAnalysis.(zoneName).(variableName).(variableValue);
                 
                statisticElement = docNode.createElement(strcat(tagsName(12)));
                statisticText= docNode.createTextNode(strcat(variableValue));
                docNode.getDocumentElement.appendChild(statisticText);
                statisticElement.appendChild(statisticText);
                
               
                valueElement = docNode.createElement(strcat(tagsName(13),num2str(a)));a=a+1;
                
                try
                    valueString=num2str(value);
                    decimalPoint=find(valueString=='.'); p=1;
                    for pt=1:1:(decimalPoint(1)+2)
                        finalValue(1,p)=valueString(pt); p=p+1;
                    end
                    try
                        expon=find(valueString=='e');
                        expon=valueString(expon:end);
                        finalValue(p:p+size(expon,2)-1)=expon;
                    catch
                    end
                catch
                    finalValue=num2str(value);
                end
                
                finalValueText= docNode.createTextNode(strcat(finalValue));%sprintf('%f',finalValue));
                docNode.getDocumentElement.appendChild(finalValueText);
                valueElement.appendChild(finalValueText);
  
                lesionElement.appendChild(statisticElement);
                lesionElement.appendChild(valueElement);
                clear finalValue
            end
        
        end
    end
     
    analysisReportElement.appendChild(structRoiInfo);
    analysisReportElement.appendChild(reportImagesElement);
    analysisReportElement.appendChild(lesionElement);
    
    if flagEnd==1
        direccionActual= cd;
        cd(reportFolder)
        xmlFileName = 'report.xml';
        xmlwrite(xmlFileName,docNode);
        cd (direccionActual)
    end

        
        
     
  
    