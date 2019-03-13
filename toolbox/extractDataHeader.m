function patientData = extractDataHeader(headerSeries)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%-Data extraction from headerSeries (header.json)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

patientData.StudyDate='';
patientData.Modality='';
patientData.InstitutionName='';
patientData.PixelSpacing1='';
patientData.PixelSpacing2='';
patientData.SpacingBetweenSlices='';
patientData.SliceThickness='';
patientData.StudyDescription='';
patientData.PatientName='';
patientData.PatientID='';
patientData.PatientBirthDate='';
patientData.PatientSex='';
patientData.TR='';
patientData.TE='';

try
    patientData.PatientName=headerSeries.x00100010.value;
catch
    patientData.PatientName='';
end
try
    patientData.PatientID=headerSeries.x00100020.value;
catch
    patientData.PatientID='';
end
try
    patientData.PatientBirthDate=headerSeries.x00100030.value;
catch
    patientData.PatientBirthDate='';
end      
try
    patientData.PatientSex=headerSeries.x00100040.value;
catch
    patientData.PatientSex='';
end   
try
    patientData.Modality=headerSeries.x00080060.value;
catch
    patientData.Modality='';
end          
try
    patientData.StudyDescription=headerSeries.x00081030.value;
catch
    patientData.StudyDescription='';
end     
try
    DateP=headerSeries.x00080020.value;
    DateP = strcat(DateP(7:8),'/',DateP(5:6),'/',DateP(1:1:4));
    patientData.StudyDate=DateP;
catch
    patientData.StudyDate='';
end  
try
    patientData.InstitutionName=headerSeries.x00080080.value;
catch
    patientData.InstitutionName='';
end      
try
    patientData.PixelSpacing1=char(headerSeries.x00280030.value(1));
    patientData.PixelSpacing2=char(headerSeries.x00280030.value(2));     
catch
    patientData.PixelSpacing1='';
    patientData.PixelSpacing2='';
end   
try
    patientData.SpacingBetweenSlices=headerSeries.x00180088.value;    
catch
    patientData.SpacingBetweenSlices='';
end               
try
    patientData.SliceThickness=headerSeries.x00180050.value;    
catch
    patientData.SliceThickness='';
end     
try
    patientData.FOV=headerSeries.x00181149.value;    
catch
    patientData.FOV='';
end  
try
    patientData.Rows=num2str(headerSeries.x00280010.value.x0x30_);    
catch
    patientData.Rows='';
end    

try
    patientData.Columns=num2str(headerSeries.x00280011.value.x0x30_);    
catch
    patientData.Columns='';
end  
try
    patientData.Intercept=headerSeries.x00281052.value;    
catch
    patientData.Intercept='';
end        
try
    patientData.Slope=headerSeries.x00281053.value;    
catch
    patientData.Slope='';
end    
try
    patientData.TR=headerSeries.x00180080.value;    
catch
    patientData.TR='';
end  
try
    patientData.TE=headerSeries.x00180081.value;    
catch
    patientData.TE='';
end

try
    if strcmp('',patientData.PixelSpacing1)
        patientData.PixelSpacing1=num2str(str2num(FOV1)./str2num(RowsP));
        patientData.PixelSpacing2=num2str(str2num(FOV2)./str2num(ColumnsP));
    end
catch
    patientData.PixelSpacing1=num2str(1);
    patientData.PixelSpacing2=num2str(1);
end

if strcmp('',patientData.SpacingBetweenSlices) && strcmp('',patientData.SliceThickness)   
    patientData.SpacingBetweenSlices=num2str(1);
    patientData.SliceThickness=num2str(1);
end

if strcmp('',patientData.SliceThickness)
    patientData.SliceThickness=patientData.SpacingBetweenSlices;
end

if strcmp('',patientData.SpacingBetweenSlices)
    patientData.SpacingBetweenSlices=patientData.SliceThickness;
end
