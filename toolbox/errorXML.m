function errorXML(err,error,PathResultados)

docNode = com.mathworks.xml.XMLUtils.createDocument('error');

idError = docNode.createElement('idError');
idErrorValue = docNode.createTextNode(sprintf('%i',error));
docNode.getDocumentElement.appendChild(idErrorValue);
docNode.getDocumentElement.appendChild(idError);
idError.appendChild(idErrorValue);

idErrorMatlab = docNode.createElement('idErrorMatlab');
idErrorMatlabValue = docNode.createTextNode(sprintf('%s',err.identifier));
docNode.getDocumentElement.appendChild(idErrorMatlabValue);
docNode.getDocumentElement.appendChild(idErrorMatlab);
idErrorMatlab.appendChild(idErrorMatlabValue);

idMessageMatlab = docNode.createElement('idMessageMatlab');
idMessageMatlabValue = docNode.createTextNode(sprintf('%s',err.message));
docNode.getDocumentElement.appendChild(idMessageMatlabValue);
docNode.getDocumentElement.appendChild(idMessageMatlab);
idMessageMatlab.appendChild(idMessageMatlabValue);

idFunctionMatlab = docNode.createElement('idFunctionMatlab');
idFunctionMatlabValue = docNode.createTextNode(sprintf('%s',err.stack.name));
docNode.getDocumentElement.appendChild(idFunctionMatlabValue);
docNode.getDocumentElement.appendChild(idFunctionMatlab);
idFunctionMatlab.appendChild(idFunctionMatlabValue);

lineMatlab = docNode.createElement('lineMatlab');
lineMatlabValue = docNode.createTextNode(sprintf('%i',err.stack.line));
docNode.getDocumentElement.appendChild(lineMatlabValue);
docNode.getDocumentElement.appendChild(lineMatlab);
lineMatlab.appendChild(lineMatlabValue);

xmlFileName = fullfile(PathResultados,'error.xml');
xmlwrite(xmlFileName,docNode);
    
end