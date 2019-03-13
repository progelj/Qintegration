function [mask, sliceNumber, imagePatPos, roiPositionNumMerge, roiInfoAll]= roi(infoAnalysis, infoDicom, headerDicom, volumeFull, NameStruc, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ROI extraction                                        %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nVarargs = length(varargin);
roiPosition={};
roiType={};
roiPositionNum=[];
roiId={};
%Matrix with Patient Image Position of all the roi's (rows)
for i=1:size(infoAnalysis.series,2)
    try
        %Check first character is a digit
        firstChar=infoAnalysis.series{1,i}.standard(1);
        if isstrprop(firstChar,'digit')
            infoAnalysis.series{1,i}.standard=strcat('seq',infoAnalysis.series{1,i}.standard);
        end
        if strcmp(infoAnalysis.series{1,i}.standard,NameStruc)
            for ii=1:size(infoAnalysis.series{1,i}.roi,2)
                roiType{ii,1}=infoAnalysis.series{1,i}.roi{1,ii}.name; 
                roiPoints{ii,1}=infoAnalysis.series{1,i}.roi{1,ii}.point1;
                roiPoints{ii,2}=infoAnalysis.series{1,i}.roi{1,ii}.point2;
                roiPoints{ii,3}=infoAnalysis.series{1,i}.roi{1,ii}.point3;
                roiPoints{ii,4}=infoAnalysis.series{1,i}.roi{1,ii}.point4;
                roiId{ii,1}=infoAnalysis.series{1,i}.roi{1,ii}.id;
                roiLabel{ii,1}=infoAnalysis.series{1,i}.roi{1,ii}.label;
                roiText{ii,1}=infoAnalysis.series{1,i}.roi{1,ii}.text;
                roiPosition=infoAnalysis.series{1,i}.roi{1,ii}.position; 
                delim=find(roiPosition==',');
                roiPositionNum(ii,1)=str2num(roiPosition(1:delim(1)-1));
                roiPositionNum(ii,2)=str2num(roiPosition(delim(1)+1:delim(2)-1));
                roiPositionNum(ii,3)=str2num(roiPosition(delim(2)+1:end));
            end
        end
    catch
        continue
    end
end   

[roiIdU,indRoi]=unique(roiId,'stable');

roiInfoAll.id=roiIdU;
roiInfoAll.label=roiLabel(indRoi);
roiInfoAll.text=roiText(indRoi);
roiInfoAll.name=roiType(indRoi);

%Extract main acquisition vector
imagePatOri=headerDicom.(NameStruc).x00200037.value;
normalDir=cross([str2num(char(imagePatOri(1))),str2num(char(imagePatOri(2))),str2num(char(imagePatOri(3)))],[str2num(char(imagePatOri(4))),str2num(char(imagePatOri(5))),str2num(char(imagePatOri(6)))]);
[normalMax,indMax]=max(normalDir); 

if nVarargs==1;
    dataInfo=varargin{1};
    imagePatPos=dataInfo.imagePatPos;
    imagePatPos=imagePatPos(1:dataInfo.dynamicLength,:);
    volumeFull=volumeFull(:,:,:,1);
else
    %Matrix with Patient Image Position of all the slices (rows)
    for i=1:size(infoDicom.(NameStruc),2)
        imagePatPos(i,1)=str2num(infoDicom.(NameStruc){1,i}.x00200032.value{1,1});
        imagePatPos(i,2)=str2num(infoDicom.(NameStruc){1,i}.x00200032.value{1,2});
        imagePatPos(i,3)=str2num(infoDicom.(NameStruc){1,i}.x00200032.value{1,3});
        SOP=infoDicom.(NameStruc){1,i}.x00080018.value;
        delim=find(SOP=='.');
        SOP=SOP(delim(end)+1:end);
        imagePatPos(i,4)=str2num(SOP);
        try
            INum=infoDicom.(NameStruc){1,i}.x00200013.value;
            imagePatPos(i,5)=str2num(INum);
        catch
            imagePatPos(i,5)=0;
        end  
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %1st Option: Sort Patient Image Position if Instance Number Present
    instanceNumbers=imagePatPos(:,5);
    [~,indPos]=sort(instanceNumbers);

    for i=1:size(imagePatPos,2)
        col=imagePatPos(:,i);
        imagePatPos(:,i)=col(indPos);
    end

    if issorted(imagePatPos(:,indMax)) || issorted(-imagePatPos(:,indMax))
        type(1)=1;
    else
        type(1)=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if type(1)==0
        %2nd Option: Sort Patient Image Position if SOP UID Present
        SOPInstUID=imagePatPos(:,4);
        [~,indPos]=sort(SOPInstUID);

        for i=1:size(imagePatPos,2)
            col=imagePatPos(:,i);
            imagePatPos(:,i)=col(indPos);
        end

        if issorted(imagePatPos(:,indMax)) || issorted(-imagePatPos(:,indMax))
            type(2)=1;
        else
            type(2)=0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if type(1)==0 && type(2)==0 
        %3rd Option: Sort Patient Image Position only
        %Extract main acquisition vector
        colAcqVector=imagePatPos(:,indMax);
        [~,indPos]=sort(colAcqVector);

        for i=1:size(imagePatPos,2)
            col=imagePatPos(:,i);
            imagePatPos(:,i)=col(indPos);
        end

        type(3)=1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

slices=size(volumeFull,3);
if ~issorted(imagePatPos(:,indMax))
    unsorted='true';
else
    unsorted='false';
end

imagePatPos=imagePatPos(:,1:3);
    
%Obtain numCorte for all roi's (comparing the roi Patient Image Position
%with the Patient Image Position of each slice).
for i=1:size(roiPositionNum,1)
    for ii=1:size(imagePatPos,1)
        comp=unique([roiPositionNum(i,:);imagePatPos(ii,:)],'rows');
        if size(comp,1)==1;
            slNumber(i)=ii;
        end
    end
end

if strcmp(unsorted,'true')
    slNumber=slices+1-slNumber;
%     numCorte=sort(numCorte);
end

for i=1:size(roiType,1)
    type=char(roiType{i,1});
    switch type
        case 'RECTANGLE'
            puntoX=str2num(roiPoints{i,1});
            puntoY=str2num(roiPoints{i,2});
            anchoX=str2num(roiPoints{i,3});
            anchoY=str2num(roiPoints{i,4});
            
            c = [puntoX, puntoX, puntoX+anchoX, puntoX+anchoX];
            r = [puntoY, puntoY+anchoY, puntoY+anchoY, puntoY];  
            
            corte=volumeFull(:,:,slNumber);
            currentMask(:,:,i) = roipoly(corte,c,r);
            currentMask(:,:,i) = double(currentMask(:,:,i));
%             im=sc(sc(mascara(:,:,i))+sc(VolumenFull(:,:,numCorte)));
%             sc(im);

        case 'ELLIPSE'
            centroX=str2num(roiPoints{i,1});
            centroY=str2num(roiPoints{i,2});
            semiaxX=str2num(roiPoints{i,3});
            semiaxY=str2num(roiPoints{i,4});
            
            Xo=[centroX,centroY]; 
            X1=[centroX+semiaxX,centroY];
            X2=[centroX,centroY+semiaxY];
              
            c1=abs(Xo(1)-X1(1));
            c2=abs(Xo(2)-X2(2));
            
            %Ellipse bug corrected
            X0=Xo(1); %Coordinate X
            Y0=Xo(2); %Coordinate Y
            l=c1; %Length
            w=c2; %Width
            
            corte=volumeFull(:,:,slNumber);
            [X Y] = meshgrid(1:size(corte,2),1:size(corte,1)); %make a meshgrid: use the size of the image
            currentMask(:,:,i) = ((X-X0)/l).^2+((Y-Y0)/w).^2<=1;
            currentMask(:,:,i) = double(currentMask(:,:,i));
            
            %Old ellipse code
%             x=((Xo(1)-c1):0.1:(Xo(1)+c1)); %Creamos el vector de puntos
%             yi=sqrt(c2^2*(abs(1-((x-Xo(1)).^2)/(c1^2))))+Xo(2);
%             yii=-sqrt(c2^2*(abs(1-((x-Xo(1)).^2)/(c1^2))))+Xo(2);
% 
%             Y=[yi,yii];
%             X=[x,x];
%             mask1=poly2mask(X,Y, size(Volumen,1), size(Volumen,2));       

%             im=sc(sc(mascara(:,:,i))+sc(VolumenFull(:,:,numCorte)));
%             sc(im);

        case 'FREEFORM'
            puntos=str2num(roiPoints{i,1});
            puntosX=puntos(1:2:end);
            puntosY=puntos(2:2:end);
            
            c=puntosX;
            r=puntosY;
            
            corte=volumeFull(:,:,slNumber);
            currentMask(:,:,i) = roipoly(corte,c,r); 
            currentMask(:,:,i) = double(currentMask(:,:,i));
%             im=sc(sc(mascara(:,:,i))+sc(VolumenFull(:,:,numCorte)));
%             sc(im);

        case 'SPLINE'
            puntos=str2num(roiPoints{i,1});
            x=puntos(1:2:end);
            y=puntos(2:2:end);
            puntosControl=str2num(roiPoints{i,2});
            xControl=puntosControl(1:2:end);
            yControl=puntosControl(2:2:end);
            
            xy=[x;y];
            xy=xy';
            xyControl=[xControl;yControl];
            xyControl=xyControl';
           
            t = linspace(0,1)';
            tam=length(xy);
            %Bezier curve generator
            bez = @(t,P) ... 
            bsxfun(@times,(1-t).^3,P(1,:)) + ...
            bsxfun(@times,3*(1-t).^2.*t,P(2,:)) + ...
            bsxfun(@times,3*(1-t).^1.*t.^2,P(3,:)) + ...
            bsxfun(@times,t.^3,P(4,:));
            XTot=[];
            %We iterate each control point. Kinetic JS always inserts 2
            %points in between a pair of control points
            %(bezier cubic curve: cp,p,p,cp,p,p,cp...) which means that for
            %"bez" to work we feed it with an array consisting on 
            %(cp,p,p,cp). We store all the points resulting from the 
            %interpolation in XTot.
            for jj=1:length(xyControl)
                for ii=1:length(xy)
                    if isequal(round(xy(ii,:)),round(xyControl(jj,:)))
                        try
                            X = bez(t,xy(ii:ii+3,:));
                        catch
                            X = bez(t,[xy(end,:);xy(1:3,:)]);
                        end
                        XTot=[XTot; X];
%                         plot(X(:,1),X(:,2));
%                         hold on;
%                         plot(xy(:,1),xy(:,2),'o')
%                         hold on;
                    end
                end
            end
            c=XTot(:,1)';
            r=XTot(:,2)';
            corte=volumeFull(:,:,slNumber);
            currentMask(:,:,i) = roipoly(corte,c,r); 
            currentMask(:,:,i) = double(currentMask(:,:,i));
%             im=sc(sc(mascara(:,:,i))+sc(VolumenFull(:,:,numCorte)));
%             sc(im);
    end
    maskId = strcat('roi_',char(roiId(i)));
    try
        indId=size(mask.(maskId),3)
    catch
        indId=0;
        mask.(maskId)=zeros(size(volumeFull));
        %This roiPositionNumMerge will only have the Image Patient
        %Position of the first slice for each roi to later use
        %ensureSlice.m to confirm if the slice selected corresponds 
        %to the correct one in the dicom series
        roiPositionNumMerge(i,:)=roiPositionNum(i,:);
    end
    if length(unique(mask.(maskId)(:,:,slNumber(i))))==1;
        mask.(maskId)(:,:,slNumber(i))=currentMask(:,:,i);
    else
        mask.(maskId)(:,:,slNumber(i))=mask.(maskId)(:,:,slNumber(i))+currentMask(:,:,i);
        maskProv=mask.(maskId)(:,:,slNumber(i));
        maskProv(maskProv>1)=1;
        mask.(maskId)(:,:,slNumber(i))=maskProv;
    end
    clear('mascara')
    try
        indNumCorte=size(sliceNumber.(maskId),2);
    catch
        indNumCorte=0;
    end
    sliceNumber.(maskId)(indNumCorte+1)=slNumber(i);
end

for ii=1:size(roiType,1)
    maskId = strcat('roi_',char(roiId(ii)));
    sliceNumber.(maskId)=unique(sliceNumber.(maskId));
end
    
