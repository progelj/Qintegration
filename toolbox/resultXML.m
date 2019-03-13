function docNode=resultXML(analysis,identifier, resultsFolder, docNode, flagEnd, roiInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generation of result.xml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Name = {'biomarker', 'identifier', 'zone', 'output', 'statistic', 'name', 'value'};
NameEnEs = {'nameEs', 'nameEn', 'descriptionEs', 'descriptionEn'};            

if docNode==0
    docNode = com.mathworks.xml.XMLUtils.createDocument('biomarker');

    %Append identifier
    NameIdentifier = docNode.createElement(strcat(Name(2)));
    nameIden = docNode.createTextNode(sprintf('%s',identifier));
    docNode.getDocumentElement.appendChild(nameIden);
    docNode.getDocumentElement.appendChild(NameIdentifier);
    NameIdentifier.appendChild(nameIden);

end

nameStructure = cellstr(fieldnames(analysis)); 
sizeStructure = size(nameStructure);

for i=1:1:sizeStructure(1)-2
    cellStructure = char(nameStructure(end-1)); 
    nameZoneEn = analysis.(cellStructure);
    nameZone=nameZoneEn(i);

    cellStructureDescription = char(nameStructure(end)); 
    zoneDescriptionEsEn = analysis.(cellStructureDescription);
    DescriptionZones=zoneDescriptionEsEn(:,i);

    zoneElement = docNode.createElement(strcat(Name(3))); 

    identifierName = docNode.createElement(strcat(Name(2)));
    identifierNameROI = docNode.createElement('roiId');
    nameZoneEsElement = docNode.createElement(strcat(NameEnEs(1)));
    nameZoneEnElement = docNode.createElement(strcat(NameEnEs(2))); 
    DescriptionEs = docNode.createElement(strcat(NameEnEs(3)));
    DescriptionEn = docNode.createElement(strcat(NameEnEs(4))); 

    entryNameIdentif = docNode.createTextNode(strcat(nameStructure(i)));
    nameIdenROI = docNode.createTextNode(sprintf('%s',char(roiInfo.id)));
    entryzoneEs = docNode.createTextNode(strcat(nameStructure(i)));
    entryzoneEn = docNode.createTextNode(strcat(nameZone));
    entryDescriptionEs = docNode.createTextNode(strcat(DescriptionZones(1)));
    entryDescriptionEn = docNode.createTextNode(strcat(DescriptionZones(2)));

    docNode.getDocumentElement.appendChild(entryNameIdentif);
    docNode.getDocumentElement.appendChild(nameIdenROI);
    docNode.getDocumentElement.appendChild(entryzoneEs);
    docNode.getDocumentElement.appendChild(entryzoneEn);
    docNode.getDocumentElement.appendChild(entryDescriptionEs);
    docNode.getDocumentElement.appendChild(entryDescriptionEn);

    docNode.getDocumentElement.appendChild(identifierName);
    docNode.getDocumentElement.appendChild(identifierNameROI);
    docNode.getDocumentElement.appendChild(nameZoneEsElement);
    docNode.getDocumentElement.appendChild(nameZoneEnElement);
    docNode.getDocumentElement.appendChild(zoneElement);
    docNode.getDocumentElement.appendChild(DescriptionEs);
    docNode.getDocumentElement.appendChild(DescriptionEn);

    identifierName.appendChild(entryNameIdentif);
    identifierNameROI.appendChild(nameIdenROI);
    nameZoneEsElement.appendChild(entryzoneEs);
    nameZoneEnElement.appendChild(entryzoneEn); 
    DescriptionEs.appendChild(entryDescriptionEs);
    DescriptionEn.appendChild(entryDescriptionEn);

    %Append optional info
    zoneElement.appendChild(identifierName);
    zoneElement.appendChild(identifierNameROI);
    zoneElement.appendChild(nameZoneEsElement);
    zoneElement.appendChild(nameZoneEnElement); 
    zoneElement.appendChild(DescriptionEs);
    zoneElement.appendChild(DescriptionEn);
    
    %%%%%%% Info ROI 
    fieldsRoiInfo = cellstr(fieldnames(roiInfo));
    sizeRoiInfo = size(fieldsRoiInfo);
    structRoiInfo = docNode.createElement(strcat('RoiInfo'));
    docNode.getDocumentElement.appendChild(structRoiInfo);
    for j=1:sizeRoiInfo(1) 
        fieldRoiInfo = char(fieldsRoiInfo(j));
        valueFieldRoiInfo = roiInfo.(fieldRoiInfo);
        label = docNode.createElement(strcat(fieldRoiInfo));
        value = docNode.createTextNode(strcat(valueFieldRoiInfo));
        docNode.getDocumentElement.appendChild(value);
        docNode.getDocumentElement.appendChild(label);
        label.appendChild(value);
        structRoiInfo.appendChild(label);
    end
    
    zoneElement.appendChild(DescriptionEs);
    zoneElement.appendChild(DescriptionEn);
    
    %Append ROI info
    zoneElement.appendChild(structRoiInfo);

    NameZone = char(nameStructure(i));
    AllVariables = analysis.(NameZone);
    AllVariables_cell = cellstr(fieldnames(AllVariables));   
    sizeVariables = size(AllVariables_cell);

    for j=1:1:sizeVariables(1)

        ElementVariable = docNode.createElement(strcat(Name(4)));
        NameVariable = docNode.createElement(strcat(Name(2)));

        entryVariable = docNode.createTextNode(strcat(AllVariables_cell(j)));

        docNode.getDocumentElement.appendChild(entryVariable);
        docNode.getDocumentElement.appendChild(NameVariable);
        docNode.getDocumentElement.appendChild(ElementVariable);

        NameVariable.appendChild(entryVariable);
        ElementVariable.appendChild(NameVariable);

        AllVariablesName = char(AllVariables_cell(j));
        AllStatistics = analysis.(NameZone).(AllVariablesName);
        AllStatistics_cell = cellstr(fieldnames(AllStatistics));
        sizeStatistics = size(AllStatistics_cell);

        for k=1:1:sizeStatistics(1)
            statisticElement = docNode.createElement(strcat(Name(5)));

            statisticName = docNode.createElement(strcat(Name(2)));
            statisticValue = docNode.createElement(strcat(Name(7)));

            entryStatistic = docNode.createTextNode(strcat(AllStatistics_cell(k)));
            variableValue = char(AllStatistics_cell(k));
            value = analysis.(NameZone).(AllVariablesName).(variableValue);
            statisticV = docNode.createTextNode(sprintf('%s',value));
            if ischar(value)
                statisticV = docNode.createTextNode(value);
            else
                statisticV = docNode.createTextNode(sprintf('%f',value));
            end

            docNode.getDocumentElement.appendChild(statisticValue);
            docNode.getDocumentElement.appendChild(statisticV);
            docNode.getDocumentElement.appendChild(entryStatistic);
            docNode.getDocumentElement.appendChild(statisticName);
            docNode.getDocumentElement.appendChild(statisticElement);

            statisticName.appendChild(entryStatistic); 
            statisticValue.appendChild(statisticV);    

            statisticElement.appendChild(statisticName);
            statisticElement.appendChild(statisticValue);
            ElementVariable.appendChild(statisticElement);
            zoneElement.appendChild(ElementVariable);

        end
    end
end    

if flagEnd==1
    currentPath= cd;
    cd(resultsFolder)
    xmlFileName = 'result.xml';
    xmlwrite(xmlFileName,docNode);
    cd(currentPath)
end

  